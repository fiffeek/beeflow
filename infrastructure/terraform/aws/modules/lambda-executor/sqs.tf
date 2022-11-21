module "sqs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "executor-sqs"
  context = module.this
}

resource "aws_sqs_queue" "executor_sqs" {
  name                       = module.sqs_label.id
  tags                       = module.sqs_label.tags
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1000
  receive_wait_time_seconds  = 10
}
