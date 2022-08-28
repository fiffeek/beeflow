include "root" {
  path = find_in_parent_folders()
}

dependency "airflow_appconfig" {
  config_path = "../airflow-appconfig"
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/scheduler"
}

inputs = {
  name                                     = "scheduler"
  repository_url                           = "239132468951.dkr.ecr.us-east-2.amazonaws.com/scheduler"
  image_tag                                = "latest"
  appconfig_application_name               = dependency.airflow_appconfig.outputs.application_name
  appconfig_application_configuration_name = dependency.airflow_appconfig.outputs.application_configuration_name
  vpc_sg                                   = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                               = dependency.vpc.outputs.private_subnet_ids
}
