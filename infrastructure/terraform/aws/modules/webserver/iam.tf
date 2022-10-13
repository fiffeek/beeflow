resource "aws_iam_role" "role" {
  name = module.this.id
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [
            "build.apprunner.amazonaws.com",
            "tasks.apprunner.amazonaws.com"
          ]
        },
        "Effect": "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  role = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}


data "aws_iam_policy_document" "airflow_logs" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      var.airflow_logs_bucket_arn,
      "${var.airflow_logs_bucket_arn}/*"
    ]
  }
}

module "airflow_logs_label" {
  source = "cloudposse/label/null"
  version = "0.25.0"
  name = "webserver-airflow-logs"
  context = module.this
}

resource "aws_iam_policy" "airflow_logs" {
  name = module.airflow_logs_label.id
  policy = data.aws_iam_policy_document.airflow_logs.json
}

resource "aws_iam_role_policy_attachment" "airflow_logs" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.airflow_logs.arn
}

resource "aws_iam_role_policy_attachment" "outside" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.appconfig_access.arn
}

module "appconfig_access_label" {
  source = "cloudposse/label/null"
  version = "0.25.0"
  name = "${module.this.name}-appconfig-access"
  context = module.this
}

resource "aws_iam_policy" "appconfig_access" {
  name = module.appconfig_access_label.id
  path = "/"
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
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}
