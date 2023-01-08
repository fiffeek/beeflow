include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "testing_buckets" {
  config_path = "../testing-buckets"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/testing/mwaa"
}

inputs = {
  name                    = "mwaa"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  min_workers             = 1
  max_workers             = 20
  celery_worker_autoscale = "10,10"
  metadata_dumps_bucket = {
    id             = dependency.testing_buckets.outputs.metadata_dumps_bucket_id,
    arn            = dependency.testing_buckets.outputs.metadata_dumps_bucket_arn,
    name           = dependency.testing_buckets.outputs.metadata_dumps_bucket_name,
    offload_prefix = "mwaa",
  }
  user_names_to_allow_cli_access = [
  "fmikina"]
  enabled = include.root.locals.enable_resources_for_testing
}
