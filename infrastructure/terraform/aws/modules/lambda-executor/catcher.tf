module "catcher_lambda_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  attributes = [
  "catcher"]
  context = module.this
}

module "catcher_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                            = var.airflow_home
  configuration_bucket_name               = var.configuration_bucket_name
  configuration_bucket_airflow_config_key = var.configuration_bucket_airflow_config_key
  configuration_bucket_arn                = var.configuration_bucket_arn
  airflow_cloudwatch_logs_group_arn       = var.airflow_cloudwatch_logs_group_arn
  airflow_logs_bucket_arn                 = var.airflow_logs_bucket_arn
  spec = {
    timeout = 180
    additional_environment_variables = {
      BEEFLOW__DAGS_BUCKET_NAME                                = var.dags_code_bucket.name
      BEEFLOW__LAMBDA_EXECUTOR_STATE_MACHINE__INPUT_FIELD_NAME = local.input_field_name
    }
    memory_size                    = 512
    reserved_concurrent_executions = -1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  is_lambda_dockerized = true
  is_lambda_packaged   = false
  lambda_dockerized_spec = {
    repository_url = var.catcher_lambda.repository_url
    image_tag      = var.catcher_lambda.image_tag
  }

  context = module.catcher_lambda_label
}


data "aws_iam_policy_document" "catcher_readonly_dags_access" {
  statement {
    sid = "ReadonlyDAGsLambdaExecutorCatcher"
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

module "catcher_readonly_dags_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.catcher_lambda_label
}

resource "aws_iam_policy" "catcher_readonly_dags_access" {
  name   = module.catcher_readonly_dags_access_label.id
  policy = data.aws_iam_policy_document.catcher_readonly_dags_access.json
}

resource "aws_iam_role_policy_attachment" "catcher_readonly_dags_access" {
  role       = module.catcher_lambda.role_name
  policy_arn = aws_iam_policy.catcher_readonly_dags_access.arn
}
