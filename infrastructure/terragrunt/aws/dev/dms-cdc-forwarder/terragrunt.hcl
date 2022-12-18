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

dependency "dms" {
  config_path = "../dms"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/dms-cdc-forwarder"
}

inputs = {
  name                                     = "dms-cdc-forwarder"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  package_absolute_path                    = "${get_repo_root()}/dist/src.python.beeflow.lambdas.dms_cdc_forwarder/package.zip"
  package_filename                         = "src.python.beeflow.lambdas.dms_cdc_forwarder.zip"
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  lambda_code_bucket_name                  = dependency.buckets.outputs.lambda_code_bucket_name
  airflow_cloudwatch_logs_group_arn        = dependency.cloudwatch_logs.outputs.airflow_events_arn
  kinesis_stream_arn                       = dependency.dms.outputs.kinesis_stream_arn
}
