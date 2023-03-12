include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/metadata-database"
}

inputs = {
  name              = "metadata-database"
  vpc_id            = dependency.vpc.outputs.vpc_id
  vpc_sg            = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids        = dependency.vpc.outputs.private_subnet_ids
  max_connections   = "350"
  instance_class    = "db.t3.micro"
  sql_proxy_enabled = false
}
