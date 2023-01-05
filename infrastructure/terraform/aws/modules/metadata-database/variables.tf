variable "vpc_id" {
  type        = string
  description = "The Id of the VPC to run RDS in."
}

variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to allow connections to RDS from."
}

variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
}

variable "database_user" {
  type        = string
  description = "Username for the master DB user"
}

variable "database_port" {
  type        = number
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of the created private subnets"
}

variable "max_connections" {
  type        = string
  description = "Maximum number of connections to the database"
}

variable "instance_class" {
  type        = string
  description = "The instance class of the RDS database"
}
