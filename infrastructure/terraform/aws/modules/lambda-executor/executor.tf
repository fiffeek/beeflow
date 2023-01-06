module "executor_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  airflow_cloudwatch_logs_group_arn        = var.airflow_cloudwatch_logs_group_arn
  appconfig_application_name               = var.appconfig_application_name
  airflow_logs_bucket_arn                  = var.airflow_logs_bucket_arn
  spec = {
    timeout = 180
    additional_environment_variables = {
      BEEFLOW__DAGS_BUCKET_NAME                                = var.dags_code_bucket.name
      BEEFLOW__LAMBDA_EXECUTOR_STATE_MACHINE__ARN              = module.lambda_executor_wrapper.state_machine_arn
      BEEFLOW__LAMBDA_EXECUTOR_STATE_MACHINE__INPUT_FIELD_NAME = local.input_field_name
    }
    memory_size                    = 256
    reserved_concurrent_executions = -1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  is_lambda_dockerized = false
  is_lambda_packaged   = true

  lambda_packaged_spec = {
    lambda_code_bucket_name     = var.lambda_code_bucket_name
    package_absolute_path       = var.lambda_executor_package_absolute_path
    package_filename            = var.lambda_executor_package_filename
    pants_lambda_entrypoint     = var.pants_lambda_entrypoint
    pants_lambda_python_version = var.pants_lambda_python_version
  }

  context = module.this
}

data "aws_iam_policy_document" "allow_sqs_pull" {
  statement {
    sid = "AllowSQSExecutorPull"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.executor_sqs.arn
    ]
  }
}

module "sqs_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "executor-sqs-wait"
  context = module.this
}

resource "aws_iam_policy" "allow_sqs_pull" {
  name   = module.sqs_access_label.id
  policy = data.aws_iam_policy_document.allow_sqs_pull.json
}

resource "aws_iam_role_policy_attachment" "allow_sqs_pull" {
  role       = module.executor_lambda.role_name
  policy_arn = aws_iam_policy.allow_sqs_pull.arn
}

resource "aws_lambda_event_source_mapping" "executor_sqs_trigger" {
  event_source_arn = aws_sqs_queue.executor_sqs.arn
  function_name    = module.executor_lambda.arn
  batch_size       = 10
}

data "aws_iam_policy_document" "sfn_invoke_access" {
  statement {
    actions = [
      "states:ListActivities",
      "states:CreateActivity",
      "states:DescribeStateMachine",
      "states:StartExecution",
      "states:ListExecutions",
      "states:DescribeExecution",
      "states:DescribeStateMachineForExecution",
      "states:GetExecutionHistory",
      "states:StopExecution",
      "states:DescribeActivity",
      "states:DeleteActivity",
      "states:GetActivityTask",
      "states:SendTaskHeartbeat"
    ]
    resources = [
      module.lambda_executor_wrapper.state_machine_arn
    ]
  }
}

module "sfn_invoke_access" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "lambda-executor-sfn-wrapper-access"
  context = module.this
}

resource "aws_iam_policy" "sfn_invoke_access" {
  name   = module.sfn_invoke_access.id
  policy = data.aws_iam_policy_document.sfn_invoke_access.json
}

resource "aws_iam_role_policy_attachment" "sfn_invoke_access" {
  role       = module.executor_lambda.role_name
  policy_arn = aws_iam_policy.sfn_invoke_access.arn
}
