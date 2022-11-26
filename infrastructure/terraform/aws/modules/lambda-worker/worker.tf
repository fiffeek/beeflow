module "worker_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  airflow_cloudwatch_logs_group_arn        = var.airflow_cloudwatch_logs_group_arn
  appconfig_application_name               = var.appconfig_application_name
  spec = {
    timeout = var.task_timeout
    additional_environment_variables = merge({
      BEEFLOW__DAGS_BUCKET_NAME = var.dags_code_bucket.name
    }, var.additional_environment_variables)
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
    sid = "ReadonlyDAGsLambdaWorker"
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
  name    = "worker-readonly-dags-access"
  context = module.this
}

resource "aws_iam_policy" "readonly_dags_access" {
  name   = module.readonly_dags_access_label.id
  policy = data.aws_iam_policy_document.readonly_dags_access.json
}

resource "aws_iam_role_policy_attachment" "readonly_dags_access" {
  role       = module.worker_lambda.role_name
  policy_arn = aws_iam_policy.readonly_dags_access.arn
}
