module "vpc" {
  count = module.this.enabled ? 1 : 0

  source  = "cloudposse/vpc/aws"
  version = "1.1.0"

  cidr_block                      = var.vpc_cidr_block
  ipv6_enabled                    = false
  default_security_group_deny_all = false

  context = module.this.context
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = module.vpc[0].vpc_default_security_group_id
}

module "subnets" {
  count = module.this.enabled ? 1 : 0

  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.40.1"

  availability_zones = var.availability_zones
  vpc_id             = module.vpc[0].vpc_id
  igw_id             = module.vpc[0].igw_id
  cidr_block         = module.vpc[0].vpc_cidr_block

  # Instance instead of gateway to reduce costs
  nat_gateway_enabled  = false
  nat_instance_type    = "t2.micro"
  nat_instance_enabled = true

  context = module.this.context
}

locals {
  enable_endpoints = (var.vpc_endpoints_enabled || var.vpc_gateway_enabled) && var.context.enabled
  interfaces       = ["ecr"]
  interface_vpc_endpoints = var.vpc_endpoints_enabled ? {
    "ecr.dkr" = {
      name                = "ecr.dkr"
      security_group_ids  = [module.endpoint_security_groups[local.interfaces[0]].id, module.vpc[0].vpc_default_security_group_id]
      subnet_ids          = module.subnets[0].private_subnet_ids
      policy              = null
      private_dns_enabled = true
    }
    "ecr.api" = {
      name                = "ecr.api"
      security_group_ids  = [module.endpoint_security_groups[local.interfaces[0]].id, module.vpc[0].vpc_default_security_group_id]
      subnet_ids          = module.subnets[0].private_subnet_ids
      policy              = null
      private_dns_enabled = true
    }
  } : {}
}

# Enable VPC endpoints if needed
module "vpc_endpoints" {
  source  = "cloudposse/vpc/aws//modules/vpc-endpoints"
  version = "2.0.0"
  count   = local.enable_endpoints ? 1 : 0

  context = module.this.context
  vpc_id  = module.vpc[0].vpc_id

  gateway_vpc_endpoints = {
    "s3" = {
      name = "s3"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "s3:*",
            ]
            Effect    = "Allow"
            Principal = "*"
            Resource  = "*"
          },
        ]
      })
      route_table_ids = concat([module.vpc[0].vpc_default_route_table_id], module.subnets[0].private_route_table_ids)
    }
  }

  interface_vpc_endpoints = local.interface_vpc_endpoints
}

module "endpoint_security_groups" {
  for_each = var.context.enabled ? toset(local.interfaces) : []
  source   = "cloudposse/security-group/aws"
  version  = "2.0.0"

  create_before_destroy      = true
  preserve_security_group_id = false
  attributes                 = [each.value]
  vpc_id                     = module.vpc[0].vpc_id

  rules = [{
    key              = "vpc_ingress"
    type             = "ingress"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = compact(concat([module.vpc[0].vpc_cidr_block], module.vpc[0].additional_cidr_blocks))
    ipv6_cidr_blocks = compact(concat([module.vpc[0].vpc_ipv6_cidr_block], module.vpc[0].additional_ipv6_cidr_blocks))
    description      = "Ingress from VPC to ${each.value}"
  }]

  allow_all_egress = true

  context = module.this.context
}

resource "aws_security_group_rule" "vpce_access" {
  count = local.enable_endpoints ? 1 : 0

  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = [module.vpc[0].vpc_cidr_block]
  description       = "Access to all VPCE."
  security_group_id = module.vpc[0].vpc_default_security_group_id
}


resource "aws_security_group_rule" "vpc_gateway_access" {
  count = local.enable_endpoints ? 1 : 0

  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  prefix_list_ids   = [module.vpc_endpoints[0].gateway_vpc_endpoints_map["s3"].prefix_list_id]
  description       = "Access to S3 gateway."
  security_group_id = module.vpc[0].vpc_default_security_group_id
}

