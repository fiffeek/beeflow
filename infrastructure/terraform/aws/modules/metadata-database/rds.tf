# Encapsulated in a module for later rework with Aurora and RDS proxy

locals {
  engine = "postgres"
}

module "metadata_database" {
  source  = "cloudposse/rds/aws"
  version = "0.38.4"

  database_name     = var.database_name
  database_user     = var.database_user
  database_password = module.random_password.secret
  database_port     = var.database_port

  multi_az            = false
  storage_type        = "gp2"
  allocated_storage   = 20
  engine              = local.engine
  engine_version      = "13.7"
  instance_class      = "db.t3.micro"
  db_parameter_group  = "postgres13"
  publicly_accessible = false
  vpc_id              = var.vpc_id
  apply_immediately   = true
  subnet_ids          = var.subnet_ids
  security_group_ids = [
  var.vpc_sg]

  db_parameter = [
    {
      name         = "rds.logical_replication"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "wal_sender_timeout"
      value        = "0"
      apply_method = "immediate"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pg_stat_statements,pglogical"
      apply_method = "pending-reboot"
    }
  ]

  context = module.this.context
}
