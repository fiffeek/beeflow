resource "aws_ecr_repository" "repository" {
  name                 = var.migrations_runner
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}
