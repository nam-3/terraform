provider "aws" {
    region = var.region
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    tags = {
        Name = "Main"
        Location = "Seoul"
    }
}

resource "aws_subnet" "subnets" {
    count = length(data.aws_availability_zones.azs.names)

    vpc_id = "${aws_vpc.main.id}"
    # https://developer.hashicorp.com/terraform/language/functions/element
    cidr_block = element(var.vsubnet_cidr, count.index)  # element(list, index)

    tags = {
        Name = "Subnet-${count.index+1}"
    }
}

