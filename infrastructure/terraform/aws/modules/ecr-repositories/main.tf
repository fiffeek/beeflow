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

resource "aws_ecr_repository" "scheduler" {
  name                 = var.scheduler
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "lambda_executor" {
  name                 = var.lambda_executor
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}
