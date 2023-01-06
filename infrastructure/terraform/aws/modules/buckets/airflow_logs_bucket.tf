module "airflow_logs_bucket" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "airflow-logs-bucket"
  context = module.this
}

resource "aws_s3_bucket" "airflow_logs_bucket" {
  bucket = module.airflow_logs_bucket.id
  acl    = "private"
}

locals {
  airflow_logs_key = "logs"
}

resource "aws_s3_bucket_object" "logs_folder" {
    bucket = module.airflow_logs_bucket.id
    acl    = "private"
    key    = "${local.airflow_logs_key}/"
    source = "/dev/null"
}
