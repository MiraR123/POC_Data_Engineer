import sys
import time
import boto3
import logging
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lag, unix_timestamp, to_timestamp, trim
from pyspark.sql.window import Window
from awsglue.context import GlueContext
from awsglue.utils import getResolvedOptions
from urllib.parse import urlparse


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

def move_source_files_to_archive(source_s3_path):
    s3_client = boto3.client('s3')
    parsed = urlparse(source_s3_path)
    bucket = parsed.netloc
    prefix = parsed.path.lstrip('/')

    archive_prefix = prefix.replace("source/", "archive/")  

    response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)

    if 'Contents' not in response:
        logger.info("No files found in source folder to move.")
        return

    for obj in response['Contents']:
        source_key = obj['Key']
        if source_key.startswith(archive_prefix):
            continue
        dest_key = source_key.replace(prefix, archive_prefix, 1)
        logger.info(f"Copying {source_key} to {dest_key}")
        s3_client.copy_object(Bucket=bucket, CopySource={'Bucket': bucket, 'Key': source_key}, Key=dest_key)
        s3_client.delete_object(Bucket=bucket, Key=source_key)
        logger.info(f"Moved {source_key} to {dest_key}")

def main():
    try:
        
        args = getResolvedOptions(
            sys.argv,
            ['JOB_NAME', 'athena_database', 'athena_output', 'source_table', 'output_path', 'source_s3_path']
        )

        sc = SparkContext()
        glueContext = GlueContext(sc)
        spark = glueContext.spark_session

        athena_client = boto3.client('athena')

        logger.info("Starting Athena query execution...")
        query = f"""
        SELECT * FROM {args['source_table']}
        """

        response = athena_client.start_query_execution(
            QueryString=query,
            QueryExecutionContext={'Database': args['athena_database']},
            ResultConfiguration={'OutputLocation': args['athena_output']}
        )

        query_execution_id = response['QueryExecutionId']

        # Wait for Athena query to complete
        state = 'RUNNING'
        while state in ['RUNNING', 'QUEUED']:
            response = athena_client.get_query_execution(QueryExecutionId=query_execution_id)
            state = response['QueryExecution']['Status']['State']
            if state in ['FAILED', 'CANCELLED']:
                raise Exception(f'Athena query failed or was cancelled: {response}')
            time.sleep(5)

        logger.info(f"Athena query {query_execution_id} completed.")

        result_s3_path = f"{args['athena_output']}{query_execution_id}.csv"

        logger.info(f"Reading Athena query results from {result_s3_path}")
        df = spark.read.option("header", True).csv(result_s3_path)

        # Preprocessing and cleaning 
        required_cols = ["user_id", "event_time"]
        optional_cols = ["event_type"]

        present_cols = df.columns
        missing_required = [c for c in required_cols if c not in present_cols]
        if missing_required:
            raise Exception(f"Missing required columns: {missing_required}")

        cols_to_use = required_cols + [c for c in optional_cols if c in present_cols]
        df = df.select(*cols_to_use)

        for c in df.columns:
            if df.schema[c].dataType.simpleString() == "string":
                df = df.withColumn(c, trim(col(c)))

        df = df.withColumn("event_time", to_timestamp(col("event_time"), "M/d/yyyy h:mm"))
        df = df.dropna(subset=required_cols)
        df = df.dropDuplicates()

        window_spec = Window.partitionBy("user_id").orderBy("event_time")
        df = df.withColumn("prev_time", lag("event_time").over(window_spec))
        df = df.withColumn("lag_minutes",
                           (unix_timestamp("event_time") - unix_timestamp("prev_time")) / 60)

        logger.info(f"Writing cleaned data to {args['output_path']}")
        df.coalesce(1).write.mode("overwrite").option("header", "true").csv(args['output_path'])

        logger.info("Output loaded to target.")

        # Move processed source files to archive
        logger.info("Starting to move processed source files to archive...")
        move_source_files_to_archive(args['source_s3_path'])
        logger.info("Processed source files moved to archive successfully.")

        logger.info("Glue job completed successfully.")

    except Exception as e:
        logger.error(f"Glue job failed: {e}", exc_info=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
