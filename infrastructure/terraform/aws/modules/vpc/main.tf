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

