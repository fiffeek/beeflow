module "aws_key_pair" {
  source = "cloudposse/key-pair/aws"
  version = "0.18.0"
  attributes = [
    "ssh"]
  ssh_public_key_path = var.ssh_key_path
  generate_ssh_key = var.generate_ssh_key

  context = module.this.context
}

module "ec2_bastion" {
  source = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.1"

  enabled = module.this.enabled

  subnets = var.public_subnet_ids
  security_groups = [
    var.vpc_sg]
  key_name = module.aws_key_pair.key_name
  associate_public_ip_address = true
  vpc_id = var.vpc_id

  context = module.this.context
}
