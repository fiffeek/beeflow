output "lambda_code_bucket_name" {
  value       = aws_s3_bucket.lambda_code_bucket.bucket
  description = "The name of a bucket storing lambda code."
}

output "dags_code_bucket_name" {
  value       = aws_s3_bucket.dags_storage.bucket
  description = "The name of a bucket storing DAGs code."
}

output "dags_code_bucket_arn" {
  value       = aws_s3_bucket.dags_storage.arn
  description = "The ARN of a bucket storing DAGs code."
}

output "dags_code_bucket_id" {
  value       = aws_s3_bucket.dags_storage.id
  description = "The ID of a bucket storing DAGs code."
}
