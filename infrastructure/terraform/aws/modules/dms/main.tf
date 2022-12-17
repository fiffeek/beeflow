module "database_migration_service" {
  source  = "terraform-aws-modules/dms/aws"
  version = "1.6.1"
  count   = module.this.enabled ? 1 : 0

  # Subnet group
  repl_subnet_group_name        = module.this.id
  repl_subnet_group_description = "DMS Subnet group"
  repl_subnet_group_subnet_ids  = var.subnet_ids

  # Instance
  repl_instance_allocated_storage            = var.replication_instance_storage_size
  repl_instance_auto_minor_version_upgrade   = true
  repl_instance_allow_major_version_upgrade  = true
  repl_instance_apply_immediately            = true
  repl_instance_engine_version               = "3.4.7"
  repl_instance_multi_az                     = false
  repl_instance_preferred_maintenance_window = "sun:10:30-sun:14:30"
  repl_instance_publicly_accessible          = false
  repl_instance_class                        = var.replication_instance_tier
  repl_instance_id                           = module.this.id
  repl_instance_vpc_security_group_ids = [
  var.vpc_sg]

  endpoints = {
    source = {
      database_name               = var.metadata_db_spec.database
      endpoint_id                 = module.this.id
      endpoint_type               = "source"
      engine_name                 = var.metadata_db_spec.engine_name
      extra_connection_attributes = "heartbeatFrequency=1;"
      username                    = var.metadata_db_spec.username
      password                    = var.metadata_db_spec.password
      port                        = var.metadata_db_spec.port
      server_name                 = split(":", var.metadata_db_spec.endpoint)[0]
      ssl_mode                    = "none"
      tags = {
        EndpointType = "source"
      }
    }
    destination = {
      endpoint_id   = module.kinesis.id
      endpoint_type = "target"
      engine_name   = "kinesis"

      kinesis_settings = {
        service_access_role_arn        = aws_iam_role.kinesis.arn
        stream_arn                     = aws_kinesis_stream.cdc_stream[0].arn
        partition_include_schema_table = true
        include_partition_value        = true
      }
      tags = {
        EndpointType = "destination"
      }
    }
  }

  replication_tasks = {
    cdc = {
      replication_task_id       = module.this.id
      migration_type            = "cdc"
      replication_task_settings = jsonencode(local.task_settings)
      table_mappings            = jsonencode(local.table_mappings)
      start_replication_task    = true

      source_endpoint_key = "source"
      target_endpoint_key = "destination"
      tags                = { Task = "PostgreSQL-to-Kinesis" }
    }
  }
  event_subscriptions = {}

  tags = module.this.tags
}
