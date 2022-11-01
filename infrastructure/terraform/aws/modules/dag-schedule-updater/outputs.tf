output "dag_schedule_updater_sqs_arn" {
  value       = aws_sqs_queue.dag_schedule_updater_sqs.arn
  description = "The ARN of the SQS queue feeding the dag schedule updater"
}

output "dag_schedule_updater_sqs_id" {
  value       = aws_sqs_queue.dag_schedule_updater_sqs.id
  description = "The id of the SQS queue feeding the dag schedule updater"
}
