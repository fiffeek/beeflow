locals {
  auth = [
    {
      auth_scheme = "SECRETS"
      description = "Access the database instance using username and password from AWS Secrets Manager"
      iam_auth    = "DISABLED"
      secret_arn  = var.sql_proxy_enabled ? aws_secretsmanager_secret.rds_username_and_password[0].arn : ""
    }
  ]

  username_password = {
    username = var.database_user
    password = module.random_password.secret
  }

  proxy_enabled = var.sql_proxy_enabled ? 1 : 0
}

resource "aws_secretsmanager_secret" "rds_username_and_password" {
  count                   = local.proxy_enabled
  name                    = module.this.id
  description             = "RDS username and password"
  recovery_window_in_days = 0
  tags                    = module.this.tags
}

resource "aws_secretsmanager_secret_version" "rds_username_and_password" {
  count         = local.proxy_enabled
  secret_id     = aws_secretsmanager_secret.rds_username_and_password[0].id
  secret_string = jsonencode(local.username_password)
}

module "rds_proxy" {
  source  = "cloudposse/rds-db-proxy/aws"
  version = "1.1.0"
  count   = local.proxy_enabled

  db_instance_identifier = module.metadata_database.instance_id
  auth                   = local.auth
  vpc_security_group_ids = [var.vpc_sg]
  vpc_subnet_ids         = var.subnet_ids

  debug_logging                = false
  engine_family                = "POSTGRESQL"
  max_connections_percent      = 70
  max_idle_connections_percent = 70

  context = module.this.context
}
