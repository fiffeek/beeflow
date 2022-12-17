variable "replication_instance_tier" {
  type = string

}

variable "replication_instance_storage_size" {
  type = number
}

variable "vpc_sg" {
  type        = string
  description = "The Id of the VPC security group to allow connections to RDS from."
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of the created private subnets"
}

variable "metadata_db_spec" {
  type = object({
    username : string,
    password : string,
    endpoint : string,
    database : string,
    port : string,
    engine_name : string,
  })
}