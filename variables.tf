variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "source_bucket_name" {
  description = "S3 bucket for source data"
  default     = "my-poc-source-bucket-unique-123"
}

variable "target_bucket_name" {
  description = "S3 bucket for target data"
  default     = "my-poc-target-bucket-unique-123"
}

variable "code_bucket_name" {
  description = "S3 bucket for glue scripts"
  default     = "my-poc-glue-code-bucket-unique-123"
}

variable "glue_database_name" {
  description = "Glue database name"
  type        = string
  default     = "user"
}

variable "source_crawler_name" {
  description = "Glue source crawler name"
  type        = string
  default     = "source-user-crawler"
}

variable "target_crawler_name" {
  description = "Glue target crawler name"
  type        = string
  default     = "target-result-crawler"
}

variable "source_table_name" {
  description = "Glue table name created by the source crawler"
  type        = string
  default     = "source"  
}

