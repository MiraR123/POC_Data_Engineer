resource "aws_s3_bucket" "source_data_bucket" {
  bucket        = var.source_bucket_name
  force_destroy = true
}

resource "aws_s3_object" "source_csv_object" {
  bucket = aws_s3_bucket.source_data_bucket.bucket
  key    = "source/user_events.csv"
  source = "${path.module}/scripts/user_events.csv"
}

resource "aws_s3_bucket" "target_data_bucket" {
  bucket        = var.target_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "glue_code_bucket" {
  bucket        = var.code_bucket_name
  force_destroy = true
}

resource "aws_s3_object" "glue_script_object" {
  bucket = aws_s3_bucket.glue_code_bucket.bucket
  key    = "scripts/script.py"
  source = "${path.module}/scripts/script.py"
}
