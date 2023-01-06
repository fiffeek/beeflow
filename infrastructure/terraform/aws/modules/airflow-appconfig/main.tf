data "template_file" "airflow_cfg" {
  template = file("${path.module}/airflow.tpl")
  vars = {
    database_user                     = var.database_user
    database_password                 = var.database_password
    database_endpoint                 = var.database_endpoint
    database_port                     = var.database_port
    database_name                     = var.database_name
    airflow_cloudwatch_logs_group_arn = var.airflow_cloudwatch_logs_group_arn
    logging_type                      = var.logging_type
    airflow_logs_bucket_name          = var.airflow_logs_bucket_name
    airflow_logs_bucket_key           = var.airflow_logs_bucket_key
  }
}

module "airflow_appconfig" {
  count = module.this.enabled ? 1 : 0

  source  = "terraform-aws-modules/appconfig/aws"
  version = "1.1.1"

  name        = module.this.id
  description = "Airflow AppConfig"

  environments = {
    (var.environment) = {
      name        = var.environment
      description = var.environment
    }
  }

  # hosted config version
  use_hosted_configuration           = true
  hosted_config_version_content_type = "text/plain"
  hosted_config_version_content      = data.template_file.airflow_cfg.rendered

  tags = module.this.tags
}
