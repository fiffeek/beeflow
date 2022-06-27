resource "aws_s3_bucket_object" "code" {
  count       = var.is_lambda_packaged ? 1 : 0
  bucket      = var.lambda_packaged_spec.lambda_code_bucket_name
  key         = var.lambda_packaged_spec.package_filename
  source      = var.lambda_packaged_spec.package_absolute_path
  source_hash = filemd5(var.lambda_packaged_spec.package_absolute_path)
}