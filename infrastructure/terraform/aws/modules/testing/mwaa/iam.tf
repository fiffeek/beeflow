data "aws_iam_policy_document" "dumps_bucket_access" {
  statement {
    sid = "ReadWriteTestingBucketMWAAWorker"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      var.metadata_dumps_bucket.arn,
      "${var.metadata_dumps_bucket.arn}/*"
    ]
  }
}

module "dumps_bucket_access" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["dumps", "bucket"]
  context    = module.this.context
}

resource "aws_iam_policy" "dumps_bucket_access" {
  name   = module.dumps_bucket_access.id
  policy = data.aws_iam_policy_document.dumps_bucket_access.json
  count  = module.this.enabled ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "testing_bucket_access" {
  role       = split("/", module.mwaa.execution_role_arn)[1]
  policy_arn = aws_iam_policy.dumps_bucket_access[0].arn
  count      = module.this.enabled ? 1 : 0
}

data "aws_iam_policy_document" "allow_cli_calls" {
  statement {
    actions = [
      "airflow:CreateCliToken",
    ]
    resources = [
      "*"
    ]
  }
}

module "allow_cli_calls" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["cli", "airflow"]
  context    = module.this.context
}

resource "aws_iam_policy" "allow_cli_calls" {
  name   = module.allow_cli_calls.id
  policy = data.aws_iam_policy_document.allow_cli_calls.json
  count  = module.this.enabled ? 1 : 0
}

resource "aws_iam_user_policy_attachment" "allow_cli_calls" {
  for_each   = toset(var.user_names_to_allow_cli_access)
  user       = each.key
  policy_arn = aws_iam_policy.allow_cli_calls[0].arn
}
