module "kinesis" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["kinesis"]
  context    = module.this
}

resource "aws_iam_policy" "kinesis" {
  name        = module.kinesis.id
  path        = "/"
  description = "A policy which grants permission to Kinesis from DMS."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        Effect   = "Allow"
        Resource = aws_kinesis_stream.cdc_stream[0].arn
      },
    ]
  })
}
resource "aws_iam_role" "kinesis" {
  name = module.kinesis.id
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  role       = aws_iam_role.kinesis.name
  policy_arn = aws_iam_policy.kinesis.arn
}

resource "aws_kinesis_stream" "cdc_stream" {
  name             = module.kinesis.name
  retention_period = 24
  count            = module.kinesis.enabled ? 1 : 0

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags        = module.kinesis.tags
  shard_count = 0
}
