include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/vpc"
}

inputs = {
  name = "vpc"
  availability_zones = [
  "us-east-2a", "us-east-2b"]
  vpc_cidr_block = "172.16.0.0/16"
}
