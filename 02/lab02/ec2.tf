#######################################
# 1. provider
# 2. EC2
# - SG
# - EC2(keypair)
#######################################

#######################################
# 1. provider
#######################################
provider "aws" {
  region = "us-east-2"
}

#######################################
# 2. EC2
#######################################
data "aws_vpc" "default" {
  default = true
}

# SG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "Allow TLS inbound SSH traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id 

  tags = {
    Name = "mysg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"  # *client ip -> server
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# * AMI ID 자동 선택하도록 data source를 사용
#   - Amazon linux 2023 ami
data "aws_ami" "amazon2023" {
  most_recent = true   # 가장 최신 버전을 선택하겠다.

  filter {
    name   = "name"
    # aws에서 AMI 카탈로그의 이미지 ID 를 복사 후에
    # AMI 탭에 붙여놓고 퍼블릭 이미지를 검색한다. - AMI 이름 부분을 copy하여 하위에 붙여넣는다.
    values = ["al2023-ami-2023.9.20251208.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # AMI 이미지의 소유자 계정 ID를 복사하여 붙여넣는다.
  owners = ["137112412989"] # Canonical
}

# key pair 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub") # 클라우드는 퍼블릭 키를 가져야 함
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.mysg.id]

  key_name = "mykeypair"

  tags = {
    Name = "myInstance"
  }
}

output "ami_id" {
  description = "AMI ID"
  value = aws_instance.myInstance.ami
}

output "myInstanceIP" {
  description = "My Instance Public IP"
  value = aws_instance.myInstance.public_ip
}

output "connectSSH" {
  description = "Connect URI"
  value = "ssh -i ~/.ssh/mykeypair ec2-user@${aws_instance.myInstance.public_ip}"
}

