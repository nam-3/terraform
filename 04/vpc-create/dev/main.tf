provider "aws" {
  region = var.aws_region
}

module "my_vpc" {
  source = "../modules/vpc"

  # vpc_cidr_block = "" -> 값을 직접 지정하거나, 하위 모듈의 값을 끌어올땐 module.myvpc.output의 이름을 지정
  # vpc_cidr = "192.168.10.0/24"
  # subnet_cidr = "192.168.10.0/25" # 25 = bit 하나를 추가해서 네트워크를 두개로 쪼갠것 중 첫번째 네트워크를 의미함

}

module "my_ec2" {
  source = "../modules/ec2"

            # ec2 모듈의 subnet_id라는 outputs지정
  subnet_id = module.my_vpc.subnet_id
}

