resource "random_pet" "random_password" {}

module "password_secret_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  name    = "database-password-${random_pet.random_password.id}"
  context = module.this
}

module "random_password" {
  source      = "git::https://github.com/rhythmictech/terraform-aws-secretsmanager-random-secret"
  name        = module.password_secret_label.id
  description = "Airflow metadata DB password"
  length      = 48
  use_special = false

  tags = module.password_secret_label.tags
}
