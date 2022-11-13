module "lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  airflow_cloudwatch_logs_group_arn        = var.airflow_cloudwatch_logs_group_arn
  appconfig_application_name               = var.appconfig_application_name
  spec = {
    timeout = 180
    additional_environment_variables = {
      AIRFLOW__WEBSERVER__UPDATE_FAB_PERMS = "false",
    }
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
