resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = module.this.id
  subnets            = var.private_subnet_ids
  security_groups = [
  var.vpc_sg]
}

resource "aws_apprunner_auto_scaling_configuration_version" "webserver" {
  auto_scaling_configuration_name = module.this.id

  max_size = 1
  min_size = 1

  tags = module.this.tags
}

locals {
  runtime_args_base = {
    BEEFLOW__APP_CONFIG_NAME                      = var.appconfig_application_configuration_name,
    BEEFLOW__APPLICATION                          = var.appconfig_application_name,
    POWERTOOLS_SERVICE_NAME                       = module.this.id,
    POWERTOOLS_LOGGER_LOG_EVENT                   = "true"
    AIRFLOW__WEBSERVER__WEB_SERVER_MASTER_TIMEOUT = "600"
    AIRFLOW_HOME                                  = var.airflow_home,
    AIRFLOW_CONN_AWS_DEFAULT                      = "aws://"
    BEEFLOW__ENVIRONMENT                          = module.this.environment,
    PYTHONUNBUFFERED                              = "1",
    AIRFLOW__WEBSERVER__UPDATE_FAB_PERMS          = "false",
    # https://stackoverflow.com/a/52451737
    FORWARDED_ALLOW_IPS = "*",
  }
}

resource "aws_apprunner_service" "webserver" {
  service_name = module.this.id

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.role.arn
    }

    image_repository {
      image_configuration {
        port                          = var.port
        runtime_environment_variables = local.runtime_args_base
      }
      image_identifier      = "${var.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.webserver.arn

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }

  health_check_configuration {
    interval            = 20
    path                = "/health"
    protocol            = "HTTP"
    unhealthy_threshold = 20
    timeout             = 10
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.role.arn
  }

  tags = module.this.tags
}
