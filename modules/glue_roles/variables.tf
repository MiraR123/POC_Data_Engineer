variable "glue_service_role_name" {
  description = "Name of the Glue service IAM role"
  type        = string
  default     = "glue_service_role"
}

variable "source_bucket_name" {
  description = "Source S3 bucket name"
  type        = string
}

variable "target_bucket_name" {
  description = "Target S3 bucket name"
  type        = string
}

variable "code_bucket_name" {
  description = "Glue code S3 bucket name"
  type        = string
}

