output "scheduler_sqs_arn" {
  value       = aws_sqs_queue.scheduler_sqs.arn
  description = "The ARN of the SQS queue feeding the scheduler"
}

output "scheduler_sqs_id" {
  value       = aws_sqs_queue.scheduler_sqs.id
  description = "The id of the SQS queue feeding the scheduler"
}
