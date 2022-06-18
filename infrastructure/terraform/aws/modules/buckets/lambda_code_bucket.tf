module "lambda_code_bucket_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "lambda-code-bucket"
  context = module.this
}

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = module.lambda_code_bucket_label.id
  acl    = "private"
}
