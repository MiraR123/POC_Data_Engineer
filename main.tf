
module "s3_buckets" {
  source            = "./modules/s3_buckets"
  source_bucket_name = var.source_bucket_name
  target_bucket_name = var.target_bucket_name
  code_bucket_name   = var.code_bucket_name
}


module "catalog_crawler" {
  source               = "./modules/catalog_crawler"
  glue_database_name   = var.glue_database_name
  source_bucket        = module.s3_buckets.source_bucket_name
  target_bucket        = module.s3_buckets.target_bucket_name
  glue_service_role_arn = module.glue_roles.glue_service_role_arn
  source_crawler_name  = var.source_crawler_name
  target_crawler_name  = var.target_crawler_name

  depends_on = [
    module.glue_roles
  ]
}

module "glue_roles" {
  source             = "./modules/glue_roles"
  glue_service_role_name = "glue_service_role"
  source_bucket_name  = var.source_bucket_name
  target_bucket_name  = var.target_bucket_name
  code_bucket_name    = var.code_bucket_name
}

module "glue_jobs" {
  source               = "./modules/glue_jobs"
  job_name             = "event-transform-job"
  glue_service_role_arn = module.glue_roles.glue_service_role_arn
  code_bucket_name     = var.code_bucket_name
  script_name          = "script.py"
  target_bucket_name   = var.target_bucket_name
  max_retries          = 1
  glue_version         = "4.0"
  number_of_workers    = 2
  worker_type          = "G.1X"

  athena_database       = var.glue_database_name
  source_table          = var.source_table_name
  source_s3_path        = "s3://${module.s3_buckets.source_bucket_name}/source/"
  source_bucket_name    = module.s3_buckets.source_bucket_name 



  depends_on_code_bucket = module.s3_buckets.code_bucket_name
  depends_on_glue_role   = module.glue_roles.glue_service_role_name
}

module "glue_workflow" {
  source        = "./modules/glue_workflow"
  workflow_name = "daily-etl-workflow"
}

module "glue_triggers" {
  source              = "./modules/glue_triggers"
  workflow_name       = module.glue_workflow.name
  source_crawler_name = module.catalog_crawler.source_crawler_name
  target_crawler_name = module.catalog_crawler.target_crawler_name
  etl_job_name        = module.glue_jobs.glue_job_name
}


