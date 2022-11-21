module "processor_sqs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-parsing-processor-sqs"
  context = module.this
}

resource "aws_sqs_queue" "dag_parsing_processor_funnel" {
  name                       = "${module.processor_sqs_label.id}.fifo"
  tags                       = module.processor_sqs_label.tags
  visibility_timeout_seconds = 310
  message_retention_seconds  = 1000
  receive_wait_time_seconds  = 20

  fifo_queue                  = true
  content_based_deduplication = true
}

data "aws_iam_policy_document" "allow_push_to_funnel" {
  statement {
    sid = "AllowPushToSQSDAGProcessingFunnel"
    actions = [
      "sqs:SendMessage",
    ]
    resources = [
      aws_sqs_queue.dag_parsing_processor_funnel.arn
    ]
  }
}

module "allow_push_to_funnel" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "allow-dag-processor-push"
  context = module.this
}

resource "aws_iam_policy" "allow_push_to_funnel" {
  name   = module.allow_push_to_funnel.id
  policy = data.aws_iam_policy_document.allow_push_to_funnel.json
}

resource "aws_iam_role_policy_attachment" "allow_push_to_funnel" {
  role       = module.trigger_processing_lambda.role_name
  policy_arn = aws_iam_policy.allow_push_to_funnel.arn
}
