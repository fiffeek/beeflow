module "configuration_bucket" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "config-bucket"
  context = module.this
}

resource "aws_s3_bucket" "configuration_bucket" {
  bucket = module.configuration_bucket.id
  tags   = module.configuration_bucket.tags
}

resource "aws_s3_bucket_acl" "configuration_bucket" {
  bucket = aws_s3_bucket.configuration_bucket.id
  acl    = "private"
}
