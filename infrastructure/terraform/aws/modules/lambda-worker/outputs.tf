output "worker_role_name" {
  value       = module.worker_lambda.role_name
  description = "The name of the execution role associated with the lambda executor"
}

output "worker_lambda_arn" {
  value       = module.worker_lambda.arn
  description = "The ARN of the lambda that will server as worker to execute Airflow tasks"
}
