output "glue_service_role_arn" {
  description = "ARN of the Glue service IAM role"
  value       = aws_iam_role.glue_service_role.arn
}

output "glue_service_role_name" {
  description = "Name of the Glue service IAM role"
  value       = aws_iam_role.glue_service_role.name
}
