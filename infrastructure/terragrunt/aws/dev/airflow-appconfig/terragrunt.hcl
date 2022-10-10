include "root" {
  path = find_in_parent_folders()
}

dependency "metadata_database" {
  config_path = "../metadata-database"
}

dependency "buckets" {
  config_path = "../buckets"
}

terraform {
  source = "${get_path_to_repo_root()}//infrastructure/terraform/aws/modules/airflow-appconfig"
}

inputs = {
  name                     = "airflow-appconfig"
  database_endpoint        = dependency.metadata_database.outputs.instance_endpoint
  database_password        = dependency.metadata_database.outputs.database_password
  airflow_logs_bucket_name = dependency.buckets.outputs.airflow_logs_bucket_name
  airflow_logs_bucket_key  = dependency.buckets.outputs.airflow_logs_bucket_key
}
