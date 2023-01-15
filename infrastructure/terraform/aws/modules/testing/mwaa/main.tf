data "aws_region" "current" {}

module "mwaa" {
  source                = "cloudposse/mwaa/aws"
  version               = "0.4.8"
  vpc_id                = var.vpc_id
  subnet_ids            = var.private_subnet_ids
  airflow_version       = var.airflow_version
  dag_s3_path           = "dags"
  environment_class     = var.environment_class
  min_workers           = var.min_workers
  max_workers           = var.max_workers
  webserver_access_mode = "PUBLIC_ONLY"
  region                = data.aws_region.current.name
  context               = module.this.context
  airflow_configuration_options = {
    "core.extract_metadata_s3_bucket_name" : var.metadata_dumps_bucket.name,
    "core.extract_metadata_s3_bucket_prefix" : var.metadata_dumps_bucket.offload_prefix,
    "core.default_pool_task_slot_count" : var.default_pool_size,
    "celery.worker_autoscale" : var.celery_worker_autoscale,
  }
}
