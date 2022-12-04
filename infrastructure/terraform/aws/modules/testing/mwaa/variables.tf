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
