# Encapsulated in a module for later rework with Aurora and RDS proxy

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
  engine              = "postgres"
  engine_version      = "13.4"
  instance_class      = "db.t3.micro"
  db_parameter_group  = "postgres13"
  publicly_accessible = false
  vpc_id              = var.vpc_id
  apply_immediately   = true
  availability_zone   = var.availability_zone
  security_group_ids = [
  var.vpc_sg]

  context = module.this.context
}
