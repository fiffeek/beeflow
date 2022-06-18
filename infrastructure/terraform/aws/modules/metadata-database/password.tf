module "random_password" {
  source           = "git::https://github.com/rhythmictech/terraform-aws-secretsmanager-random-secret"
  name             = module.this.id
  description      = "Airflow metadata DB password"
  length           = 20
  override_special = "@#$%^*()-=_+[]{};<>?,./"
}
