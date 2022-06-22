module "lambda" {
  source = "../airflow-private-lambda"

  airflow_home                             = var.airflow_home
  appconfig_application_configuration_name = var.appconfig_application_configuration_name
  appconfig_application_name               = var.appconfig_application_name
  lambda_code_bucket_name                  = var.lambda_code_bucket_name
  package_absolute_path                    = var.migrations_runner_package_absolute_path
  package_filename                         = var.migrations_runner_package_filename
  pants_lambda_entrypoint                  = var.pants_lambda_entrypoint
  pants_lambda_python_version              = var.pants_lambda_python_version
  spec = {
    timeout                          = 600
    additional_environment_variables = {}
    memory_size                      = 512
    reserved_concurrent_executions   = 1
  }
  subnet_ids = var.subnet_ids
  vpc_sg     = var.vpc_sg

  context = module.this
}
