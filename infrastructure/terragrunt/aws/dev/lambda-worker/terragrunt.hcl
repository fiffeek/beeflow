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

dependency "testing_buckets" {
  config_path = "../testing-buckets"
}

dependency "cloudwatch_logs" {
  config_path = "../cloudwatch-logs"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/lambda-worker"
}

inputs = {
  name                                     = "lambda_worker"
  repository_url                           = "${include.root.locals.ecr_region_path}/lambda_worker"
  image_tag                                = "latest"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
  airflow_cloudwatch_logs_group_arn        = dependency.cloudwatch_logs.outputs.airflow_events_arn
  airflow_logs_bucket_arn                  = dependency.buckets.outputs.airflow_logs_bucket_arn
  dags_code_bucket = {
    name = dependency.buckets.outputs.dags_code_bucket_name,
    arn  = dependency.buckets.outputs.dags_code_bucket_arn,
    id   = dependency.buckets.outputs.dags_code_bucket_id
  }
  task_timeout = 300
  additional_environment_variables = include.root.locals.enable_resources_for_testing ? {
    BEEFLOW__EXTRACT_METADATA_S3_BUCKET = dependency.testing_buckets.outputs.metadata_dumps_bucket_name,
    BEEFLOW__EXTRACT_METADATA_S3_PREFIX = "serverless"
  } : {}
}
