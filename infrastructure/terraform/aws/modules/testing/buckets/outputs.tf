
output "metadata_dumps_bucket_name" {
  value       = module.this.enabled ? aws_s3_bucket.metadata_dumps[0].bucket : null
  description = "The name of a bucket storing Airflow metadata database dumps."
}

output "metadata_dumps_bucket_arn" {
  value       = module.this.enabled ? aws_s3_bucket.metadata_dumps[0].arn : null
  description = "The ARN of a bucket storing Airflow metadata database dumps."
}

output "metadata_dumps_bucket_id" {
  value       = module.this.enabled ? aws_s3_bucket.metadata_dumps[0].id : null
  description = "The ID of a bucket storing Airflow metadata database dumps."
}
