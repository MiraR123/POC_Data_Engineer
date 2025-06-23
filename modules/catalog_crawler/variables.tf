variable "glue_database_name" {
  description = "Glue database name"
  type        = string
}

variable "source_bucket" {
  description = "S3 source bucket name"
  type        = string
}

variable "target_bucket" {
  description = "S3 target bucket name"
  type        = string
}

variable "glue_service_role_arn" {
  description = "IAM Role ARN for Glue service"
  type        = string
}

variable "source_crawler_name" {
  description = "Glue crawler name for source data"
  type        = string
}

variable "target_crawler_name" {
  description = "Glue crawler name for target/output data"
  type        = string
}
