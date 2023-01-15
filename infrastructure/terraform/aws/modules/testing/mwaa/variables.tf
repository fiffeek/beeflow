variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the AppRunner VPC connector."
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC to create the MWAA in."
}

variable "metadata_dumps_bucket" {
  type = object({
    id             = string,
    arn            = string
    name           = string,
    offload_prefix = string,
  })
  description = "The metadata dumps bucket"
}

variable "user_names_to_allow_cli_access" {
  type        = list(string)
  description = "List of user names to allow Airflow CLI access to."
}

variable "max_workers" {
  type        = number
  description = "The maximum number of workers for MWAA."
}

variable "min_workers" {
  type        = number
  description = "The minimum number of workers for MWAA."
}

variable "celery_worker_autoscale" {
  type        = string
  description = "Max,min tasks per worker for MWAA."
  default     = "5,5"
}

variable "default_pool_size" {
  type        = string
  description = "The default pool size for MWAA."
  default     = "256"
}

variable "environment_class" {
  type        = string
  description = "The environment class for MWAA."
  default     = "mw1.small"
}

variable "airflow_version" {
  type        = string
  description = "The version of Airflow in MWAA"
  default     = "2.4.3"
}
