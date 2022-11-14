data "aws_region" "current" {}

module "mwaa" {
  source                      = "cloudposse/mwaa/aws"
  version                     = "0.4.8"
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.private_subnet_ids
  airflow_version             = "2.2.2"
  dag_s3_path                 = "dags"
  environment_class           = "mw1.small"
  min_workers                 = 1
  max_workers                 = 1
  webserver_access_mode       = "PUBLIC_ONLY"
  region                      = data.aws_region.current.name
  context                     = module.this.context
}
