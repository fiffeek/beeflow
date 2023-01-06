variable "database_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created"
}

variable "database_user" {
  type        = string
  description = "Username for the master DB user"
}

variable "database_password" {
  type        = string
  description = "Password to the RDS database."
}

variable "database_port" {
  type        = number
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

variable "database_endpoint" {
  type        = string
  description = "DNS Endpoint of the Metadata database instance"
}

variable "airflow_cloudwatch_logs_group_arn" {
  type        = string
  description = "The ARN for the Airflow logs in cloudwatch group"
  default     = ""
}

variable "logging_type" {
  type        = string
  description = "Either `s3` or `cloudwatch` permitted"
  default     = "s3"
}

variable "airflow_logs_bucket_name" {
  type        = string
  description = "The name of the airflow logs bucket"
  default     = ""
}

variable "airflow_logs_bucket_key" {
  type        = string
  description = "The key of the Airflow logs bucket"
  default     = ""
}
