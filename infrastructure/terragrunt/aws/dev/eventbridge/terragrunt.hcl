include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/eventbridge"
}

dependency "scheduler" {
  config_path = "../scheduler"
}

dependency "lambda_executor" {
  config_path = "../lambda-executor"
}

dependency "dag_schedule_updater" {
  config_path = "../dag-schedule-updater"
}

inputs = {
  name = "events"
  scheduler_sqs = {
    arn : dependency.scheduler.outputs.scheduler_sqs_arn,
    id : dependency.scheduler.outputs.scheduler_sqs_id,
  }
  lambda_executor_sqs = {
    arn : dependency.lambda_executor.outputs.executor_sqs_arn,
    id : dependency.lambda_executor.outputs.executor_sqs_id,
  }
  dag_schedule_updater_sqs = {
    arn : dependency.dag_schedule_updater.outputs.dag_schedule_updater_sqs_arn,
    id : dependency.dag_schedule_updater.outputs.dag_schedule_updater_sqs_id,
  }
}
