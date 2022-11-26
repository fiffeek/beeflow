include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/ecr-repositories"
}

inputs = {
  migrations_runner       = "migrations_runner"
  dag_parsing_processor   = "dag_parsing_processor"
  scheduler               = "scheduler"
  lambda_executor         = "lambda_executor"
  lambda_worker           = "lambda_worker"
  lambda_executor_catcher = "lambda_executor_catcher"
  dag_schedule_updater    = "dag_schedule_updater"
  webserver               = "webserver"
  batch_executor          = "batch_executor"
  batch_worker            = "batch_worker"
  batch_executor_catcher  = "batch_executor_catcher"
  api_to_cli_forwarder    = "api_to_cli_forwarder"
}
