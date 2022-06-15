resource "aws_s3_bucket" "dags_storage" {
  bucket = module.this.id
  tags   = module.this.tags
}

resource "aws_s3_bucket_acl" "dags_storage_acl" {
  bucket = aws_s3_bucket.dags_storage.id
  acl    = "private"
}
