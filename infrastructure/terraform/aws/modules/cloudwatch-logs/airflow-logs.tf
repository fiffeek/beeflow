module "airflow_logs_label" {
  source = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
    "airflow"]
  context = module.this
}

resource "aws_cloudwatch_log_group" "airflow_logs" {
  name = module.airflow_logs_label.id
  retention_in_days = 14
  tags = module.airflow_logs_label.tags
}
