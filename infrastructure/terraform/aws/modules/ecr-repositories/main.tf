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

resource "aws_ecr_repository" "lambda_worker" {
  name                 = var.lambda_worker
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "lambda_executor_catcher" {
  name                 = var.lambda_executor_catcher
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "dag_schedule_updater" {
  name                 = var.dag_schedule_updater
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "webserver" {
  name                 = var.webserver
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "batch_executor" {
  name                 = var.batch_executor
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "batch_worker" {
  name                 = var.batch_worker
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "batch_executor_catcher" {
  name                 = var.batch_executor_catcher
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}

resource "aws_ecr_repository" "api_to_cli_forwarder" {
  name                 = var.api_to_cli_forwarder
  image_tag_mutability = "MUTABLE"
  tags                 = module.this.tags
}
