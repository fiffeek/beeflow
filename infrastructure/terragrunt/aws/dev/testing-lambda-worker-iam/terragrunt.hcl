include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/testing/lambda-worker-iam"
}

dependency "testing_buckets" {
  config_path = "../testing-buckets"
}

dependency "lambda_worker" {
  config_path = "../lambda-worker"
}

inputs = {
  name                      = "testing-lambda-worker-iam"
  lambda_executor_role_name = dependency.lambda_worker.outputs.worker_role_name
  metadata_dumps_bucket = {
    id  = dependency.testing_buckets.outputs.metadata_dumps_bucket_id,
    arn = dependency.testing_buckets.outputs.metadata_dumps_bucket_arn,
  }
  enabled = include.root.locals.enable_resources_for_testing
}
