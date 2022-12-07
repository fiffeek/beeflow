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
