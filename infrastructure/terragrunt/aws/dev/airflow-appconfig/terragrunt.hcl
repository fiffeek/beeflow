include "root" {
  path = find_in_parent_folders()
}

dependency "metadata_database" {
  config_path = "../metadata-database"
}

dependency "cloudwatch_logs" {
  config_path = "../cloudwatch-logs"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/airflow-appconfig"
}

inputs = {
  name                              = "airflow-appconfig"
  database_endpoint                 = dependency.metadata_database.outputs.instance_endpoint
  database_password                 = dependency.metadata_database.outputs.database_password
  airflow_cloudwatch_logs_group_arn = dependency.cloudwatch_logs.outputs.airflow_events_arn
}
