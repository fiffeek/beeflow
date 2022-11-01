resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${module.this.id}"
  retention_in_days = 7

  tags = module.this.tags
}
