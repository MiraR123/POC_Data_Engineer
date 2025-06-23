output "schedule_trigger_name" {
  value = aws_glue_trigger.schedule_trigger.name
}

output "conditional_trigger_name" {
  value = aws_glue_trigger.conditional_trigger.name
}
output "target_crawler_trigger_name" {
  value = aws_glue_trigger.target_crawler_trigger.name
}

