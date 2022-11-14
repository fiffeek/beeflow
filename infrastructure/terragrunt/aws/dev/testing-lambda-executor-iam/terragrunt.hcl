include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/testing/lambda-executor-iam"
}

dependency "testing_buckets" {
  config_path = "../testing-buckets"
}

dependency "lambda_executor" {
  config_path = "../lambda-executor"
}

inputs = {
  name                      = "testing-lambda-executor-iam"
  lambda_executor_role_name = dependency.lambda_executor.outputs.lambda_role_name
  metadata_dumps_bucket = {
    id  = dependency.testing_buckets.outputs.metadata_dumps_bucket_id,
    arn = dependency.testing_buckets.outputs.metadata_dumps_bucket_arn,
  }
  enabled = include.root.locals.enable_resources_for_testing
}
