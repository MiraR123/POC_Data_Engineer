output "source_bucket_name" {
  value = aws_s3_bucket.source_data_bucket.bucket
}

output "target_bucket_name" {
  value = aws_s3_bucket.target_data_bucket.bucket
}

output "code_bucket_name" {
  value = aws_s3_bucket.glue_code_bucket.bucket
}
