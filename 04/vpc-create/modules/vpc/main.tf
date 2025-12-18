#########################
# VPC 생성
#########################
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"   # tag와 resource name이 다르면 수정 가능. 같으면 수정하지 않는것이 좋다.
  }
}

#########################
# Subnet 생성
#########################
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = var.subnet_tags
}


