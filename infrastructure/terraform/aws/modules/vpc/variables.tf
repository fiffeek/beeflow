variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones."
}

variable "vpc_endpoints_enabled" {
  type        = bool
  description = "Should enable VPC endpoints for ECR."
  default     = false
}

variable "vpc_gateway_enabled" {
  type        = bool
  description = "Should enable VPC gateway for S3? This is free: https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html"
  default     = true
}
