include "root" {
  path = find_in_parent_folders()
}

dependency "airflow_appconfig" {
  config_path = "../airflow-appconfig"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "buckets" {
  config_path = "../buckets"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/migrations-runner"
}

inputs = {
  name                                     = "migrations-runner"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  migrations_runner_package_absolute_path  = "${get_repo_root()}/dist/src.python.beeflow.lambdas.migrations_runner/package.zip"
  migrations_runner_package_filename       = "src.python.beeflow.lambdas.migrations_runner.zip"
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  lambda_code_bucket_name                  = dependency.buckets.outputs.lambda_code_bucket_name
}
