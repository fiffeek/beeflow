module "airflow_logs" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "airflow-logs"
  context = module.this
}

resource "aws_s3_bucket" "airflow_logs" {
  bucket = module.airflow_logs.id
  tags   = module.airflow_logs.tags
}

resource "aws_s3_bucket_acl" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id
  acl    = "private"
}

locals {
  folder_name = "logs"
}

resource "aws_s3_bucket_object" "logs_folder" {
    bucket = aws_s3_bucket.airflow_logs.id
    acl    = "private"
    key    = "${local.folder_name}/"
    source = "/dev/null"
}
