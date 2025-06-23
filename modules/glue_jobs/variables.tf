variable "job_name" {
  description = "Glue job name"
  type        = string
  default     = "event-transform-job"
}

variable "glue_service_role_arn" {
  description = "IAM role ARN for Glue job"
  type        = string
}

variable "code_bucket_name" {
  description = "S3 bucket name where Glue scripts are stored"
  type        = string
}

variable "script_name" {
  description = "Name of the Glue job script file"
  type        = string
  default     = "script.py"
}

variable "target_bucket_name" {
  description = "S3 bucket name for temp storage during Glue job"
  type        = string
}

variable "max_retries" {
  description = "Max retries for the Glue job"
  type        = number
  default     = 1
}

variable "glue_version" {
  description = "Glue version"
  type        = string
  default     = "4.0"
}

variable "number_of_workers" {
  description = "Number of workers"
  type        = number
  default     = 2
}

variable "worker_type" {
  description = "Worker type"
  type        = string
  default     = "G.1X"
}

variable "depends_on_code_bucket" {
  description = "Resource for depends_on code bucket"
  type        = any
}

variable "depends_on_glue_role" {
  description = "Resource for depends_on glue role"
  type        = any
}

variable "athena_database" {
  description = "Athena database name"
  type        = string
}

variable "source_table" {
  description = "Source table name from Glue crawler"
  type        = string
  default     = "source"
}
variable "source_bucket_name" {
  description = "Source S3 bucket name"
  type        = string
}

variable "source_s3_path" {
  description = "S3 path to the source folder (e.g. s3://my-poc-bucket/source/)"
  type        = string
}




