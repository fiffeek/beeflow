module "dags_code_bucket_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "dags-code-bucket"
  context = module.this
}

resource "aws_s3_bucket" "dags_storage" {
  bucket = module.dags_code_bucket_label.id
  tags   = module.dags_code_bucket_label.tags
}

resource "aws_s3_bucket_acl" "dags_storage_acl" {
  bucket = aws_s3_bucket.dags_storage.id
  acl    = "private"
}
