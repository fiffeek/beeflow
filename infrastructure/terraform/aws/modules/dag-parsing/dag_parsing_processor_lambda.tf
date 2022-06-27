module "dag_parsing_processor_lambda_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dag-parsing-processor"
  context = module.this
}


module "dag_parsing_processor_lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  appconfig_application_name               = var.appconfig_application_name
  lambda_code_bucket_name                  = var.lambda_code_bucket_name
  package_absolute_path                    = var.dag_parsing_processor_package_absolute_path
  package_filename                         = var.dag_parsing_processor_package_filename
  pants_lambda_entrypoint                  = var.pants_lambda_entrypoint
  pants_lambda_python_version              = var.pants_lambda_python_version

  spec = {
    timeout                          = 300
    additional_environment_variables = {}
    memory_size                      = 256
    reserved_concurrent_executions   = 1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  context = module.trigger_processing_lambda_label
}
