variable "source_bucket_name" {
  description = "Name of the S3 bucket to store source data"
  type        = string
}

variable "target_bucket_name" {
  description = "Name of the S3 bucket to store target/output data"
  type        = string
}

variable "code_bucket_name" {
  description = "Name of the S3 bucket to store Glue job scripts"
  type        = string
}
