output "glue_job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.event_transform_job.name
}

output "glue_job_arn" {
  description = "ARN of the Glue job"
  value       = aws_glue_job.event_transform_job.arn
}


