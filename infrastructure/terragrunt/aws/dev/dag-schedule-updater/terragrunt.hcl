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

dependency "scheduler" {
  config_path = "../scheduler"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/dag-schedule-updater"
}

inputs = {
  name                                     = "dag_schedule_updater"
  repository_url                           = "239132468951.dkr.ecr.us-east-2.amazonaws.com/dag_schedule_updater"
  image_tag                                = "latest"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  dags_code_bucket = {
    name = dependency.buckets.outputs.dags_code_bucket_name,
    arn  = dependency.buckets.outputs.dags_code_bucket_arn,
    id   = dependency.buckets.outputs.dags_code_bucket_id
  }
  scheduler_sqs_arn = dependency.scheduler.outputs.scheduler_sqs_arn
}