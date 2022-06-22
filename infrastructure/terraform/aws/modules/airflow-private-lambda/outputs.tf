output "arn" {
  value       = module.lambda.arn
  description = "ARN of the lambda function"
}

output "role_name" {
  description = "Lambda IAM role name"
  value       = module.lambda.role_name
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = module.lambda.role_arn
}
