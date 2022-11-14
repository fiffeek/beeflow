module "metadata_dumps_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "metadata-dumps"
  context = module.this
}

resource "aws_s3_bucket" "metadata_dumps" {
  bucket = module.metadata_dumps_label.id
  acl    = "private"
  count  = module.this.enabled ? 1 : 0
}
