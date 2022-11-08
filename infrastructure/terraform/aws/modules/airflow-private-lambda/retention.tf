resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${module.lambda.function_name}"
  retention_in_days = 14
  tags              = module.this.tags
}
