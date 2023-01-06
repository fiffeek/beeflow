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

dependency "lambda_worker" {
  config_path = "../lambda-worker"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/lambda-executor"
}

inputs = {
  name                                     = "lambda_executor"
  repository_url                           = "${include.root.locals.ecr_region_path}/lambda_executor"
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
  catcher_lambda = {
    image_tag      = "latest"
    repository_url = "${include.root.locals.ecr_region_path}/lambda_executor_catcher"
  }
  lambda_worker_arn                     = dependency.lambda_worker.outputs.worker_lambda_arn
  lambda_code_bucket_name               = dependency.buckets.outputs.lambda_code_bucket_name
  lambda_executor_package_absolute_path = "${get_repo_root()}/dist/src.python.beeflow.lambdas.lambda_executor/package.zip"
  lambda_executor_package_filename      = "src.python.beeflow.lambdas.lambda_executor.zip"
}
