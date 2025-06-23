resource "aws_glue_job" "event_transform_job" {
  name     = var.job_name
  role_arn = var.glue_service_role_arn

  command {
    name            = "glueetl"
    script_location = "s3://${var.code_bucket_name}/scripts/${var.script_name}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"              = "python"
    "--TempDir"                   = "s3://${var.target_bucket_name}/temp/"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"            = "true"
    "--enable-glue-datacatalog"   = "true"
    "--additional-python-modules" = "pyarrow"
    "--athena_database"           = var.athena_database
    "--athena_output"             = "s3://${var.source_bucket_name}/athena-results/"
    "--source_table"              = var.source_table
    "--output_path"               = "s3://${var.target_bucket_name}/output/"
    "--source_s3_path"            = var.source_s3_path
  }

  max_retries       = var.max_retries
  glue_version      = var.glue_version
  number_of_workers = var.number_of_workers
  worker_type       = var.worker_type

  
}
