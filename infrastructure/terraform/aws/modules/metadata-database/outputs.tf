output "instance_endpoint" {
  description = "DMS Endpoint of the SQL or proxy instance."
  value       = var.sql_proxy_enabled ? "${module.rds_proxy[0].proxy_endpoint}:5432" : module.metadata_database.instance_endpoint
}

output "replication_instance_endpoint" {
  description = "DMS Endpoint of the SQL instance."
  value       = module.metadata_database.instance_endpoint
}

output "database_password_secret_name" {
  description = "The name of the secret containing the password to the database instance."
  value       = module.password_secret_label.id
}

output "database_password" {
  description = "Password to the RDS database."
  value       = module.random_password.secret
  sensitive   = true
}

output "database_engine" {
  description = "The name of the engine for the database"
  value       = local.engine
}
