data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "invoke_lambda_policy" {
  name        = "invoke_lambda_policy"
  path        = "/"
  description = "A policy which grants permission to invoke a Lambda function."

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"
      },
    ]
  })
}
resource "aws_iam_role" "rds_lambda_role" {
  name               = "rds_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_lambda_role_attach" {
  role       = aws_iam_role.rds_lambda_role.name
  policy_arn = aws_iam_policy.invoke_lambda_policy.arn
}
resource "aws_db_instance_role_association" "rds_lambda_role_attach" {
  db_instance_identifier = module.metadata_database.instance_id
  feature_name           = "Lambda"
  role_arn               = aws_iam_role.rds_lambda_role.arn
}
