module "cdc_forwarder_lambda_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
  "lambda"]
  context = module.this
}


module "cdc_forwarder_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  appconfig_application_name               = var.appconfig_application_name
  is_lambda_dockerized                     = false
  is_lambda_packaged                       = true
  airflow_cloudwatch_logs_group_arn        = var.airflow_cloudwatch_logs_group_arn

  lambda_packaged_spec = {
    lambda_code_bucket_name     = var.lambda_code_bucket_name
    package_absolute_path       = var.package_absolute_path
    package_filename            = var.package_filename
    pants_lambda_entrypoint     = var.pants_lambda_entrypoint
    pants_lambda_python_version = var.pants_lambda_python_version
  }

  spec = {
    timeout = 60
    additional_environment_variables = {
      "EVENTBRIDGE_BUS_NAME" : var.beeflow_main_event_bus_name
    }
    memory_size                    = 128
    reserved_concurrent_executions = 45
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  context = module.cdc_forwarder_lambda_label
}

data "aws_iam_policy_document" "stream_policy_document" {
  statement {
    actions = [
      "kinesis:ListStreams",
      "kinesis:DescribeLimits"
    ]

    resources = [
      // extracting 'arn:${Partition}:kinesis:${Region}:${Account}:stream/' from the kinesis stream ARN
      // see https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonkinesis.html#amazonkinesis-resources-for-iam-policies
      length(regexall("arn.*\\/", var.kinesis_stream_arn)) > 0 ? "${regex("arn.*\\/", var.kinesis_stream_arn)}*" : ""
    ]
  }

  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator"
    ]

    resources = [
      var.kinesis_stream_arn
    ]
  }
}

module "kinesis" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
  "iam"]
  context = module.this
}

resource "aws_iam_policy" "stream_policy" {
  count       = module.this.enabled ? 1 : 0
  name        = module.kinesis.id
  description = "Gives permission to list and read a Kinesis stream."
  policy      = data.aws_iam_policy_document.stream_policy_document.json
}

resource "aws_iam_role_policy_attachment" "stream_policy_attachment" {
  count      = module.this.enabled ? 1 : 0
  role       = module.cdc_forwarder_lambda.role_name
  policy_arn = aws_iam_policy.stream_policy[count.index].arn
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = var.kinesis_stream_arn
  function_name     = module.cdc_forwarder_lambda.arn
  starting_position = "LATEST"
  function_response_types = [
  "ReportBatchItemFailures"]
  maximum_retry_attempts = 5
  parallelization_factor = 3
}