
# Data Engineer POC - ETL Workflow
### Mira Radhakrishnan

## Overview
This project demonstrates an end-to-end ETL workflow where Terraform is used to provision AWS infrastructure including an S3 bucket for source data and output results, Glue database and tables using crawlers, and IAM roles. A Glue Python job is defined to read source CSV data via Athena, calculate lag time between user events, and write the results back to S3 in CSV format.

## How It Works

This ETL pipeline calculates the lag time between user events by orchestrating a sequence of AWS services, all provisioned using Terraform for consistency and scalability.

### 1. Source Data Upload
- A CSV file containing user event data (e.g., login, click, logout) is uploaded to a dedicated source S3 bucket.
- The bucket is organized with folders for both incoming data and archived files.

### 2. Source Crawler Execution
- A Glue crawler (scheduled via Glue Workflow) scans the uploaded data.
- It creates or updates the metadata table in the Glue Data Catalog, allowing Athena to query the data.

### 3. Athena Query-Based Glue Job
The Glue ETL job is implemented in Python using PySpark and boto3. Key tasks include:

- **Athena Integration**:  
  Triggers an Athena query to read source data from the Glue catalog table, and waits for completion.

- **Data Cleaning & Preprocessing**:  
  Selects required columns (`user_id`, `event_time`), trims strings, converts timestamps, and removes nulls/duplicates.

- **Lag Time Calculation**:  
  Uses PySpark window functions (`lag()` over user_id partition ordered by event time) to compute time lag in minutes.

- **Output Writing**:  
  Writes the transformed data (with lag time) back to S3 in CSV format with headers.

- **Archival Logic**:  
  After processing, the source input files are moved to an `archive/` folder within the S3 bucket using boto3.

- **Logging and Error Handling**:  
  Logs each step for monitoring. On failure, the job exits with clear error logs.

### 4. Target Crawler Execution
- Once the ETL job finishes, a second Glue crawler scans the output folder.
- It updates the Glue Catalog to make the transformed data queryable for downstream use.

### 5. Workflow Automation
An AWS Glue Workflow ties all steps together:

- Starts with the **source crawler**
- Proceeds to the **Glue job** after successful cataloging
- Triggers the **target crawler** after job completion

> Currently, the workflow runs on a scheduled time-based trigger (e.g., daily), but can be modified for event-driven triggers (e.g., S3 file upload via Lambda).

### 6. Script Management via S3
- A separate S3 bucket is used to store Glue ETL scripts (`.py` files), keeping scripts decoupled from data buckets.

### 7. Archival Logic
- After successful ETL processing, source files are moved to `archive/` in the same bucket.
- This prevents reprocessing and allows traceability for new incremental uploads.


### Infrastructure Components (via Terraform)

This project provisions the following AWS infrastructure components using Terraform:

#### S3 Buckets
- **Source Bucket**:
  - Contains the raw input CSV files.
  - Hosts an `archive/` folder for processed input files.
  - Stores Athena query results in a dedicated `athena/` folder, used internally by the Glue job to read source data.
- **Target Bucket**:
  - Stores the processed output files (CSV or Parquet format).
- **Scripts Bucket**:
  - Used to centrally store the Glue job script (`.py`) that is referenced during job execution.

#### AWS Glue Components
- **Glue Database**: Logical container for source and target tables generated by crawlers.
- **Glue Crawlers**:
  - **Source Crawler**: Scans the source S3 location and creates a Glue table from the raw CSV data.
  - **Target Crawler**: Scans the output folder in the target bucket and creates a Glue table for the processed data.
- **Glue Job**:
  - Python-based job that executes an Athena query over the raw data, calculates the lag time between user events, and writes the results back to the target S3 bucket.

#### Glue Workflow and Triggers
- A Glue Workflow orchestrates the complete ETL process.
- Three Triggers ensure smooth execution:
  1. **Scheduled Trigger**: Starts the workflow periodically (can later be replaced with an event-based trigger such as S3 upload).
  2. **On Success Trigger 1**: Executes the Glue job after the source crawler finishes and the catalog table is created.
  3. **On Success Trigger 2**: Executes the target crawler after the Glue job completes successfully.

#### IAM Roles & Policies
- Glue-specific IAM roles are created with fine-grained permissions to access S3 buckets, Glue catalog, Athena query execution, and logging.


### Deployment Steps

Follow the steps below to deploy and run the ETL workflow from your local Linux machine:

- Configure AWS CLI: `aws configure`
- Initialize Terraform: `terraform init`
- Validate Terraform: `terraform validate`
- Verify the plan: `terraform plan`
- Apply the plan: `terraform apply`
- Trigger the Glue Workflow manually:
  ```bash
  aws glue start-workflow-run --glue-workflow-name


### Execution Results
For visual reference, detailed screenshots of the ETL workflow execution at each stage are provided in the etl_screenshots.pdf file included with this project.

### Future Enhancements

- Support for event-based triggering (e.g., S3 PUT event for file upload)
- Enhanced error handling and logging using Glue job bookmarks or CloudWatch alerts
- Integration of AWS Glue Data Quality for schema validation and data profiling
- Cost optimization through improved job sizing, dynamic scaling, and efficient partitioning





