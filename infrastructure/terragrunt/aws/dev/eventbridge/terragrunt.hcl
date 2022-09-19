include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/eventbridge"
}

dependency "scheduler" {
  config_path = "../scheduler"
}

inputs = {
  name = "events"
  scheduler_sqs = {
    arn : dependency.scheduler.outputs.scheduler_sqs_arn,
    id : dependency.scheduler.outputs.scheduler_sqs_id,
  }
}
