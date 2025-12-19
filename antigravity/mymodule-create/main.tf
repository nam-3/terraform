provider "aws" {
  region = var.region
}

module "net" {
  source = "./modules/net"

  vpc_cidr = var.vpc_cidr
  name_prefix = "my-project"
}

module "ec2" {
  source = "./modules/ec2"

  vpc_id    = module.net.vpc_id
  subnet_id = module.net.public_subnet_id
  name_prefix = "my-project"
}
