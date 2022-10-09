module "sqs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-schedule-updater-sqs"
  context = module.this
}

resource "aws_sqs_queue" "dag_schedule_updater_sqs" {
  name                       = module.sqs_label.id
  tags                       = module.sqs_label.tags
  visibility_timeout_seconds = 80
  message_retention_seconds  = 300
}
