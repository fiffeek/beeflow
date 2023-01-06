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

dependency "cloudwatch_logs" {
  config_path = "../cloudwatch-logs"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/cdc-forwarder"
}

inputs = {
  name                                     = "cdc-forwarder"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  package_absolute_path                    = "${get_repo_root()}/dist/src.python.beeflow.lambdas.change_data_capture_forwarder/package.zip"
  package_filename                         = "src.python.beeflow.lambdas.change_data_capture_forwarder.zip"
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  lambda_code_bucket_name                  = dependency.buckets.outputs.lambda_code_bucket_name
  airflow_cloudwatch_logs_group_arn        = dependency.cloudwatch_logs.outputs.airflow_events_arn
  airflow_logs_bucket_arn                  = dependency.buckets.outputs.airflow_logs_bucket_arn
}
