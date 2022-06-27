module "trigger_processing_lambda_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-parsing-trigger"
  context = module.this
}


module "trigger_processing_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  appconfig_application_name               = var.appconfig_application_name

  spec = {
    timeout                          = 60
    additional_environment_variables = {}
    memory_size                      = 128
    # As this is only a trigger for parsing limiting the
    # concurrency here will result in more AWS S3 events being batched on SQS
    reserved_concurrent_executions = 1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  context = module.trigger_processing_lambda_label
  is_lambda_dockerized = false
  is_lambda_packaged = false
}

data "aws_iam_policy_document" "allow_waitlist_pull" {
  statement {
    sid = "AllowDAGsParsingWaitlistPull"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.dag_parsing_wait_list.arn
    ]
  }
}

module "waitlist_pull_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-parsing-waitlist"
  context = module.this
}

resource "aws_iam_policy" "allow_waitlist_pull" {
  name   = module.waitlist_pull_label.id
  policy = data.aws_iam_policy_document.allow_waitlist_pull.json
}

resource "aws_iam_role_policy_attachment" "allow_waitlist_pull" {
  role       = module.trigger_processing_lambda.role_name
  policy_arn = aws_iam_policy.allow_waitlist_pull.arn
}

//resource "aws_lambda_event_source_mapping" "dag_files_arrival" {
//  event_source_arn                   = aws_sqs_queue.dag_parsing_wait_list.arn
//  function_name                      = module.trigger_processing_lambda.arn
//  batch_size                         = var.batch_size
//  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
//}
