include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/ecr-repositories"
}

inputs = {
  migrations_runner     = "migrations_runner"
  dag_parsing_processor = "dag_parsing_processor"
  scheduler             = "scheduler"
  lambda_executor       = "lambda_executor"
}
