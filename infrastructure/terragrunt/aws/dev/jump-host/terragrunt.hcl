include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/jump-host"
}

inputs = {
  name              = "jump-host"
  vpc_id            = dependency.vpc.outputs.vpc_id
  vpc_sg            = dependency.vpc.outputs.vpc_default_security_group_id
  public_subnet_ids = dependency.vpc.outputs.public_subnet_ids
  generate_ssh_key  = true
  ssh_key_path      = "${get_repo_root()}"
}
