data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${module.this.id}-ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "airflow_logs" {
  statement {
    actions = [
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
    resources = [
      var.airflow_cloudwatch_logs_group_arn,
      "${var.airflow_cloudwatch_logs_group_arn}:log-stream:*",
      "${var.airflow_cloudwatch_logs_group_arn}:*"
    ]
  }
}

module "airflow_logs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "${module.this.id}-airflow-logs"
  context = module.this
}

resource "aws_iam_policy" "airflow_logs" {
  name   = module.airflow_logs_label.id
  policy = data.aws_iam_policy_document.airflow_logs.json
}

resource "aws_iam_role_policy_attachment" "airflow_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.airflow_logs.arn
}

resource "aws_iam_role_policy_attachment" "appconfig_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
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


data "aws_iam_policy_document" "readonly_dags_access" {
  statement {
    sid = "ReadonlyDAGsBatchWorker"
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
  name    = "batch-worker-readonly-dags-access"
  context = module.this
}

resource "aws_iam_policy" "readonly_dags_access" {
  name   = module.readonly_dags_access_label.id
  policy = data.aws_iam_policy_document.readonly_dags_access.json
}

resource "aws_iam_role_policy_attachment" "readonly_dags_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.readonly_dags_access.arn
}

module "airflow_s3_logs" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = module.this.name
  attributes = [
  "s3", "logs"]
  context = module.this
}

resource "aws_iam_policy" "airflow_s3_logs" {
  name        = module.airflow_s3_logs.id
  path        = "/"
  description = "Access to S3 for Airflow logs storage."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Put*",
          "s3:Delete*",
        ]
        Effect = "Allow"
        Resource = [
          var.airflow_logs_bucket_arn,
          "${var.airflow_logs_bucket_arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_s3_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.airflow_s3_logs.arn
}

module "airflow_config" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = module.this.name
  attributes = [
  "config"]
  context = module.this
}

resource "aws_iam_policy" "airflow_config" {
  name        = module.airflow_config.id
  path        = "/"
  description = "Access to S3 for Airflow config storage."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Put*",
          "s3:Delete*",
        ]
        Effect = "Allow"
        Resource = [
          var.configuration_bucket_arn,
          "${var.configuration_bucket_arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_config" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.airflow_config.arn
}