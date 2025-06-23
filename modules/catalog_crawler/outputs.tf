output "glue_database_name" {
  description = "Glue database name"
  value       = aws_glue_catalog_database.user_database.name
}

output "source_crawler_name" {
  description = "Glue source crawler name"
  value       = aws_glue_crawler.user_crawler.name
}

output "target_crawler_name" {
  description = "Glue target crawler name"
  value       = aws_glue_crawler.target_result_crawler.name
}



