output "airflow_events_arn" {
  value       = aws_cloudwatch_log_group.airflow_logs.arn
  description = "The ARN of the log group for Airflow"
}
