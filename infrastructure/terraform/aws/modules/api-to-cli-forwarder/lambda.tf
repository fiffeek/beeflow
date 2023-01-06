module "lambda" {
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
