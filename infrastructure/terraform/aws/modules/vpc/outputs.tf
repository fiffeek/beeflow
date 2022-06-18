output "vpc_id" {
  value       = module.vpc[0].vpc_id
  description = "The ID of the VPC"
}

output "vpc_default_security_group_id" {
  value       = module.vpc[0].vpc_default_security_group_id
  description = "The ID of the security group created by default on VPC creation"
}

output "availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = module.subnets[0].availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.subnets[0].public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.subnets[0].private_subnet_ids
}
