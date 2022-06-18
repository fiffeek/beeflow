output "instance_endpoint" {
  description = "DNS Endpoint of the instance."
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
