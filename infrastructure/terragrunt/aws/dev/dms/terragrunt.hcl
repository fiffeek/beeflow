include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/dms"
}

dependency "metadata_database" {
  config_path = "../metadata-database"
}

locals {
  database_vars = read_terragrunt_config(find_in_parent_folders("database.hcl"))
}

inputs = {
  name                              = "dms-cdc"
  vpc_sg                            = dependency.vpc.outputs.vpc_default_security_group_id
  subnet_ids                        = dependency.vpc.outputs.private_subnet_ids
  replication_instance_storage_size = 5
  replication_instance_tier         = "dms.t3.micro"
  enabled                           = true
  metadata_db_spec = {
    username : local.database_vars.locals.database_user,
    password : dependency.metadata_database.outputs.database_password,
    endpoint : dependency.metadata_database.outputs.instance_endpoint,
    database : local.database_vars.locals.database_name,
    port : local.database_vars.locals.database_port,
    engine_name : dependency.metadata_database.outputs.database_engine,
  }
}
