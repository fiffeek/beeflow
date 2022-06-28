resource "aws_ecr_repository" "repository" {
  name                 = var.migrations_runner
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "dag_parsing_processor" {
  name                 = var.dag_parsing_processor
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}
