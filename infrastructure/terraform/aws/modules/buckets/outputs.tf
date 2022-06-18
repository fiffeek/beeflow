output "lambda_code_bucket_name" {
  value       = aws_s3_bucket.lambda_code_bucket.bucket
  description = "The name of a bucket storing lambda code."
}
