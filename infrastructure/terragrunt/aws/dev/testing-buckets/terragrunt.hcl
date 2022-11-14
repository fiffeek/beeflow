include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/testing/buckets"
}

inputs = {
  name    = "testing-buckets"
  enabled = include.root.locals.enable_resources_for_testing
}
