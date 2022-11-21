module "sqs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "scheduler-sqs"
  context = module.this
}

resource "aws_sqs_queue" "scheduler_sqs" {
  name                       = "${module.sqs_label.id}.fifo"
  tags                       = module.sqs_label.tags
  visibility_timeout_seconds = 90
  message_retention_seconds  = 300
  receive_wait_time_seconds  = 20

  fifo_queue                  = true
  content_based_deduplication = true
}
