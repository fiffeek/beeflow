variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones."
}
