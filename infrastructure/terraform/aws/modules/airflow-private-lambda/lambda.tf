module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.3.6"

  s3_bucket                      = var.is_lambda_packaged ? aws_s3_bucket_object.code[0].bucket : null
  s3_key                         = var.is_lambda_packaged ? aws_s3_bucket_object.code[0].key : null
  function_name                  = module.this.id
  handler                        = var.is_lambda_packaged ? var.lambda_packaged_spec.pants_lambda_entrypoint : null
  runtime                        = var.is_lambda_packaged ? var.lambda_packaged_spec.pants_lambda_python_version : null
  timeout                        = var.spec.timeout
  memory_size                    = var.spec.memory_size
  reserved_concurrent_executions = var.spec.reserved_concurrent_executions
  source_code_hash               = var.is_lambda_packaged ? filebase64sha256(var.lambda_packaged_spec.package_absolute_path) : ""
  image_uri                      = var.is_lambda_dockerized ? "${var.lambda_dockerized_spec.repository_url}:${var.lambda_dockerized_spec.image_tag}" : null
  package_type                   = var.is_lambda_dockerized ? "Image" : "Zip"

  vpc_config = {
    subnet_ids = var.subnet_ids
    security_group_ids = [
    var.vpc_sg]
  }

  lambda_environment = {
    variables = merge(var.spec.additional_environment_variables, {
      BEEFLOW__APP_CONFIG_NAME    = var.appconfig_application_configuration_name,
      BEEFLOW__APPLICATION        = var.appconfig_application_name,
      POWERTOOLS_SERVICE_NAME     = module.this.id,
      POWERTOOLS_LOGGER_LOG_EVENT = "true"
      AIRFLOW_HOME                = var.airflow_home,
      AIRFLOW_CONN_AWS_DEFAULT    = "aws://"
      BEEFLOW__ENVIRONMENT        = module.this.environment,
      PYTHONUNBUFFERED            = "1"
    })
  }

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "outside" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.appconfig_access.arn
}

module "appconfig_access_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "${module.this.name}-appconfig-access"
  context = module.this
}

resource "aws_iam_policy" "appconfig_access" {
  name        = module.appconfig_access_label.id
  path        = "/"
  description = "Access to AppConfig."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetDocument",
          "ssm:ListDocuments",
          "appconfig:GetLatestConfiguration",
          "appconfig:StartConfigurationSession",
          "appconfig:ListApplications",
          "appconfig:GetApplication",
          "appconfig:ListEnvironments",
          "appconfig:GetEnvironment",
          "appconfig:ListConfigurationProfiles",
          "appconfig:GetConfigurationProfile",
          "appconfig:ListDeploymentStrategies",
          "appconfig:GetDeploymentStrategy",
          "appconfig:GetConfiguration",
          "appconfig:ListDeployments",
          "appconfig:GetDeployment"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_logs" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.airflow_logs.arn
}

module "airflow_logs" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "${module.this.name}-cloudwatch-airflow-logs"
  context = module.this
}

resource "aws_iam_policy" "airflow_logs" {
  name        = module.airflow_logs.id
  path        = "/"
  description = "Access to Cloudwatch for Airflow logs storage."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:createLogStream",
          "logs:deleteLogStream",
          "logs:createLogGroup",
          "logs:cancelExportTask",
          "logs:createExportTask",
          "logs:deleteRetentionPolicy",
          "logs:describeLogStreams",
          "logs:filterLogEvents",
          "logs:getLogEvents",
          "logs:getLogEvents",
          "logs:describe*",
          "logs:get*",
          "logs:list*",
          "logs:startQuery",
          "logs:stopQuery",
          "logs:testMetricFilter",
          "logs:filterLogEvents",
          "logs:putLogEvents",
          "logs:createLogStream",
        ]
        Effect = "Allow"
        Resource = [
          var.airflow_cloudwatch_logs_group_arn,
          "${var.airflow_cloudwatch_logs_group_arn}:log-stream:*",
          "${var.airflow_cloudwatch_logs_group_arn}:*"
        ]
      },
    ]
  })
}
