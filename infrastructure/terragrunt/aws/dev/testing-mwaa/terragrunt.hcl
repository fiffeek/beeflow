include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/testing/mwaa"
}

inputs = {
  name               = "mwaa"
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  enabled            = false
}
