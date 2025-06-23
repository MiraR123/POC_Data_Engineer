resource "aws_glue_trigger" "schedule_trigger" {
  name           = "daily-source-crawler-trigger"
  type           = "SCHEDULED"
  schedule       = "cron(0 0 * * ? *)" # every 24h
  workflow_name  = var.workflow_name

  actions {
    crawler_name = var.source_crawler_name
  }

  start_on_creation = true
}

resource "aws_glue_trigger" "conditional_trigger" {
  name           = "source-crawler-success-to-etl-job"
  type           = "CONDITIONAL"
  workflow_name  = var.workflow_name

  actions {
    job_name = var.etl_job_name
  }

  predicate {
    conditions {
      crawler_name = var.source_crawler_name
      crawl_state  = "SUCCEEDED"
    }
  }

  start_on_creation = true
}

resource "aws_glue_trigger" "target_crawler_trigger" {
  name           = "etl-job-success-to-target-crawler"
  type           = "CONDITIONAL"
  workflow_name  = var.workflow_name

  actions {
    crawler_name = var.target_crawler_name
  }

  predicate {
    conditions {
      job_name = var.etl_job_name
      state    = "SUCCEEDED"
    }
  }

  start_on_creation = true
}
