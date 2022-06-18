output "application_name" {
  value       = module.this.id
  description = "The name of the AppConfig Application."
}

output "application_configuration_name" {
  value       = module.this.id
  description = "The name of the AppConfig Application Configuration."
}
