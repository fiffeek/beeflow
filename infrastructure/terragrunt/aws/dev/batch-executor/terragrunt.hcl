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

dependency "batch_worker" {
  config_path = "../batch-worker"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/batch-executor"
}

inputs = {
  name                                    = "batch_executor"
  repository_url                          = "${include.root.locals.ecr_region_path}/batch_executor"
  image_tag                               = "latest"
  configuration_bucket_name               = dependency.airflow_appconfig.outputs.airflow_configuration_bucket_name
  configuration_bucket_arn                = dependency.buckets.outputs.configuration_bucket_arn
  configuration_bucket_airflow_config_key = dependency.airflow_appconfig.outputs.configuration_bucket_airflow_config_key
  vpc_sg                                  = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                              = dependency.vpc.outputs.private_subnet_ids
  airflow_cloudwatch_logs_group_arn       = dependency.cloudwatch_logs.outputs.airflow_events_arn
  airflow_logs_bucket_arn                 = dependency.buckets.outputs.airflow_logs_bucket_arn
  job_queue_name                          = dependency.batch_worker.outputs.job_queue_name
  job_definition_name                     = dependency.batch_worker.outputs.job_definition_name
  dags_code_bucket = {
    name = dependency.buckets.outputs.dags_code_bucket_name,
    arn  = dependency.buckets.outputs.dags_code_bucket_arn,
    id   = dependency.buckets.outputs.dags_code_bucket_id
  }
  catcher_lambda = {
    repository_url = "${include.root.locals.ecr_region_path}/batch_executor_catcher",
    image_tag      = "latest"
  }
  batch_executor_package_absolute_path = "${get_repo_root()}/dist/src.python.beeflow.lambdas.batch_executor/package.zip"
  batch_executor_package_filename      = "src.python.beeflow.lambdas.batch_executor.zip"
  lambda_code_bucket_name              = dependency.buckets.outputs.lambda_code_bucket_name
}
