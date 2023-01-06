output "application_name" {
  value       = module.this.id
  description = "The name of the AppConfig Application."
}

output "application_configuration_name" {
  value       = module.this.id
  description = "The name of the AppConfig Application Configuration."
}

output "airflow_configuration_bucket_name" {
  value       = var.configuration_bucket_name
  description = "The name of the configuration bucket for Airflow."
}

output "configuration_bucket_airflow_config_key" {
  value       = var.configuration_bucket_airflow_config_key
  description = "The key in the Airflow Config bucket to pull for the config."
}
