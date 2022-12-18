output "kinesis_stream_arn" {
  value       = aws_kinesis_stream.cdc_stream[0].arn
  description = "The arn of the kinesis stream"
}
