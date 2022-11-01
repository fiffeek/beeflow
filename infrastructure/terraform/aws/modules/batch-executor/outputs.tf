output "executor_sqs_arn" {
  value       = aws_sqs_queue.executor_sqs.arn
  description = "The ARN of the SQS queue feeding the executor"
}

output "executor_sqs_id" {
  value       = aws_sqs_queue.executor_sqs.id
  description = "The id of the SQS queue feeding the executor"
}
