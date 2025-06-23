# Glue Data Catalog Database
resource "aws_glue_catalog_database" "user_database" {
  name         = var.glue_database_name
  location_uri = "s3://${var.source_bucket}/"
}

# Glue Crawler for source data
resource "aws_glue_crawler" "user_crawler" {
  name          = var.source_crawler_name
  database_name = aws_glue_catalog_database.user_database.name
  role          = var.glue_service_role_arn

  s3_target {
    path = "s3://${var.source_bucket}/source/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
  }

  configuration = jsonencode({
    Version  = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

}

# Glue Crawler for target/output data
resource "aws_glue_crawler" "target_result_crawler" {
  name          = var.target_crawler_name
  database_name = aws_glue_catalog_database.user_database.name
  role          = var.glue_service_role_arn

  s3_target {
    path = "s3://${var.target_bucket}/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
  }

  configuration = jsonencode({
    Version  = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })
}
