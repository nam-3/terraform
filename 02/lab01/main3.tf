##########################################
# 1. NAT-Gateway 생성 -> Public Subnet
# 2. Private Subnet(myVPC) 생성
# 3. Private Routing Table 생성 및 NAT 연결
# 4. SG 생성
# 5. EC2 생성
##########################################

##########################################
# 1. NAT-Gateway 생성 -> Public Subnet
# 2. Private Subnet(myVPC) 생성
# 3. Private Routing Table 생성 및 NAT 연결
# 4. SG 생성
# 5. EC2 생성
##########################################

##########################################
# 1. NAT-Gateway 생성 -> Public Subnet
##########################################
# * EIP 생성된 상태에서 작업
# * NAT Gateway를 PubSN에 생성

# EIP 생성 / eip? elastic IP - 공인 IP를 말한다.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "myEIP" {
  domain = "vpc"
  tags = {
    Name = "myEIP"
  }
}

# NAT Gateway 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "myNAT-GW" {
  allocation_id = aws_eip.myEIP.id
  subnet_id     = aws_subnet.myPubSN.id

  tags = {
    Name = "myNAT-GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.myIGW]
}


##########################################
# 2. Private Subnet(myVPC) 생성
##########################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "myPriSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24" # PubSN : 10.0.1.0/24 이므로, 겹치지 않게 설정한다.

  tags = {
    Name = "myPriSN"
  }
}

##########################################
# 3. Private Routing Table 생성 및 NAT 연결
##########################################
# * NAT Gateway를 default route 설정
# * Private Subnet에 연결
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "myPriRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNAT-GW.id
  }

  tags = {
    Name = "myPriRT"
  }
}

# 연결 작업
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "myPriRTassoc" {
  subnet_id      = aws_subnet.myPriSN.id
  route_table_id = aws_route_table.myPriRT.id
}

##########################################
# 4. SG 생성
##########################################
# * myEC2-2 가 사용할 SG
#   - 22/tcp, 80/tcp, 443/tcp
# aws_security_group 서치
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG2" {
  name        = "mySG2"
  description = "Allow TLS inbound 22/tcp, 80/tcp, 443/tcp traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG2"
  }
}

# ingress
resource "aws_vpc_security_group_ingress_rule" "mySG2_22" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_80" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "mySG2_443" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# egress
resource "aws_vpc_security_group_egress_rule" "mySG2_all" {
  security_group_id = aws_security_group.mySG2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

##########################################
# 5. EC2 생성
##########################################
# * AMI: amazon linux 2023 ami
# * mySG2를 포함
# * EC2를 Private Subnet 에 생성
# * user_data(Web Server, SSH Server)
#   - user_data가 변경 되었을 때 EC2를 재생성하도록 설정

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "myEC2-2" {
  ami           = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.mySG2.id]
  subnet_id              = aws_subnet.myPriSN.id

  # key_name 서치
  # (Optional) Key name of the Key Pair to use for the instance; 
  # which can be managed using the aws_key_pair resource.
  key_name = "mykeypair"

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    dnf install -y httpd mod_ssl
    echo "My Web Server 2 Test Page" > /var/www/html/index.html
    systemctl enable --now httpd
    EOF

  tags = {
    Name = "myEC2-2"
  }
}

