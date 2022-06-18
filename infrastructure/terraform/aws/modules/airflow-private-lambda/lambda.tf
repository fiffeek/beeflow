resource "aws_s3_bucket_object" "code" {
  bucket      = var.lambda_code_bucket_name
  key         = var.package_filename
  source      = var.package_absolute_path
  source_hash = filemd5(var.package_absolute_path)
}

module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.3.6"

  s3_bucket        = aws_s3_bucket_object.code.bucket
  s3_key           = aws_s3_bucket_object.code.key
  function_name    = module.this.id
  handler          = var.pants_lambda_entrypoint
  runtime          = var.pants_lambda_python_version
  timeout          = var.spec.timeout
  memory_size      = var.spec.memory_size
  source_code_hash = filebase64sha256(var.package_absolute_path)

  vpc_config = {
    subnet_ids = var.subnet_ids
    security_group_ids = [
    var.vpc_sg]
  }

  lambda_environment = {
    variables = merge(var.spec.additional_environment_variables, {
      BEEFLOW__APP_CONFIG_NAME = var.appconfig_application_configuration_name,
      BEEFLOW__APPLICATION     = var.appconfig_application_name,
      POWERTOOLS_SERVICE_NAME  = module.this.id,
      AIRFLOW_HOME             = var.airflow_home,
      BEEFLOW__ENVIRONMENT     = module.this.environment,
      PYTHONUNBUFFERED         = "1"
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
  name    = "appconfig-access"
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
