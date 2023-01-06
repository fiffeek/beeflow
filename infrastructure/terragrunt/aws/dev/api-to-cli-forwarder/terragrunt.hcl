include "root" {
  path   = find_in_parent_folders()
  expose = true
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
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/api-to-cli-forwarder"
}

inputs = {
  name                                    = "api-to-cli-forwarder"
  repository_url                          = "${include.root.locals.ecr_region_path}/api_to_cli_forwarder"
  image_tag                               = "latest"
  configuration_bucket_name               = dependency.airflow_appconfig.outputs.airflow_configuration_bucket_name
  configuration_bucket_arn                = dependency.buckets.outputs.configuration_bucket_arn
  configuration_bucket_airflow_config_key = dependency.airflow_appconfig.outputs.configuration_bucket_airflow_config_key
  vpc_sg                                  = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                              = dependency.vpc.outputs.private_subnet_ids
  airflow_cloudwatch_logs_group_arn       = dependency.cloudwatch_logs.outputs.airflow_events_arn
  airflow_logs_bucket_arn                 = dependency.buckets.outputs.airflow_logs_bucket_arn
}
