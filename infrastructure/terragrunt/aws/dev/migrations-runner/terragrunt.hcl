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
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/migrations-runner"
}

inputs = {
  name                                     = "migrations-runner"
  repository_url                           = "${include.root.locals.ecr_region_path}/migrations_runner"
  image_tag                                = "latest"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  airflow_cloudwatch_logs_group_arn        = dependency.cloudwatch_logs.outputs.airflow_events_arn
}
