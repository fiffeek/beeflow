module "cdc_forwarder_lambda_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "cdc-forwarder"
  context = module.this
}


module "cdc_forwarder_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                            = var.airflow_home
  configuration_bucket_name               = var.configuration_bucket_name
  configuration_bucket_airflow_config_key = var.configuration_bucket_airflow_config_key
  configuration_bucket_arn                = var.configuration_bucket_arn
  is_lambda_dockerized                    = false
  is_lambda_packaged                      = true
  airflow_cloudwatch_logs_group_arn       = var.airflow_cloudwatch_logs_group_arn
  airflow_logs_bucket_arn                 = var.airflow_logs_bucket_arn

  lambda_packaged_spec = {
    lambda_code_bucket_name     = var.lambda_code_bucket_name
    package_absolute_path       = var.package_absolute_path
    package_filename            = var.package_filename
    pants_lambda_entrypoint     = var.pants_lambda_entrypoint
    pants_lambda_python_version = var.pants_lambda_python_version
  }

  spec = {
    timeout = 60
    additional_environment_variables = {
      "EVENTBRIDGE_BUS_NAME" : var.beeflow_main_event_bus_name
    }
    memory_size                    = 128
    reserved_concurrent_executions = 45
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  context = module.cdc_forwarder_lambda_label
}
