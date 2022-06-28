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
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/dag-parsing"
}

inputs = {
  name                                      = "dags-parsing"
  appconfig_application_name                = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name  = dependency.airflow_appconfig.outputs.application_configuration_name
  dag_parsing_trigger_package_absolute_path = "${get_repo_root()}/dist/src.python.beeflow.lambdas.dag_parsing_trigger/package.zip"
  dag_parsing_trigger_package_filename      = "src.python.beeflow.lambdas.dag_parsing_trigger.zip"
  dag_parsing_processor_repository_url      = "239132468951.dkr.ecr.us-east-2.amazonaws.com/dag_parsing_processor"
  dag_parsing_processor_image_tag           = "latest"
  vpc_sg                                    = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                                = dependency.vpc.outputs.private_subnet_ids
  lambda_code_bucket_name                   = dependency.buckets.outputs.lambda_code_bucket_name
  batch_size                                = 100
  maximum_batching_window_in_seconds        = 60
  dag_files_arrival_queue_enabled           = false
  dags_code_bucket = {
    name = dependency.buckets.outputs.dags_code_bucket_name,
    arn  = dependency.buckets.outputs.dags_code_bucket_arn,
    id   = dependency.buckets.outputs.dags_code_bucket_id
  }
}