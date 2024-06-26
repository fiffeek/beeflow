module "lambda" {
  source = "../airflow-private-lambda"

  airflow_home                            = var.airflow_home
  configuration_bucket_name               = var.configuration_bucket_name
  configuration_bucket_airflow_config_key = var.configuration_bucket_airflow_config_key
  configuration_bucket_arn                = var.configuration_bucket_arn
  airflow_cloudwatch_logs_group_arn       = var.airflow_cloudwatch_logs_group_arn
  airflow_logs_bucket_arn                 = var.airflow_logs_bucket_arn
  spec = {
    timeout = 80
    additional_environment_variables = {
      BEEFLOW__DAGS_BUCKET_NAME       = var.dags_code_bucket.name
      AIRFLOW__LOGGING__LOGGING_LEVEL = "DEBUG"
    }
    memory_size                    = 512
    reserved_concurrent_executions = -1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  is_lambda_dockerized = true
  is_lambda_packaged   = false
  lambda_dockerized_spec = {
    repository_url = var.repository_url
    image_tag      = var.image_tag
  }

  context = module.this
}


data "aws_iam_policy_document" "readonly_dags_access" {
  statement {
    sid = "ReadonlyDAGAccessScheduler"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      var.dags_code_bucket.arn,
      "${var.dags_code_bucket.arn}/*"
    ]
  }
}

module "readonly_dags_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "scheduler-readonly-dags-access"
  context = module.this
}

resource "aws_iam_policy" "readonly_dags_access" {
  name   = module.readonly_dags_access_label.id
  policy = data.aws_iam_policy_document.readonly_dags_access.json
}

resource "aws_iam_role_policy_attachment" "readonly_dags_access" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.readonly_dags_access.arn
}

data "aws_iam_policy_document" "allow_sqs_pull" {
  statement {
    sid = "AllowSQSSchedulerPull"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.scheduler_sqs.arn
    ]
  }
}

module "sqs_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "scheduler-sqs-wait"
  context = module.this
}

resource "aws_iam_policy" "allow_sqs_pull" {
  name   = module.sqs_access_label.id
  policy = data.aws_iam_policy_document.allow_sqs_pull.json
}

resource "aws_iam_role_policy_attachment" "allow_sqs_pull" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.allow_sqs_pull.arn
}

resource "aws_lambda_event_source_mapping" "scheduler_sqs_trigger" {
  event_source_arn = aws_sqs_queue.scheduler_sqs.arn
  function_name    = module.lambda.arn
  batch_size       = 10
}

