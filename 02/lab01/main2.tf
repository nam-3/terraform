#####################################################
# 1. SG 생성
# 2. EC2 생성
#####################################################

#############################
# 1. SG 생성
#############################
# SG 생성
# * ingress: 80/tcp, 443/tcp
# * egress : 전체 허용
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

# ingress 22
# ssh -i ~/.ssh/mykeypair ec2-user@18.217.250.7
# 접속 후 cd ~/.ssh
# cat > ~/.ssh/mykeypair   복붙 후 <ctrl> + <d>
# 해당 pri key는 온프레미스의 cat ~/.ssh/mykeypair
# -----BEGIN OPENSSH PRIVATE KEY----- ~ ...  -----END OPENSSH PRIVATE KEY-----
# mykeypair 생성한 뒤 chmod 400 mykeypair 로 퍼미션 조정해줘야 함
resource "aws_vpc_security_group_ingress_rule" "mySG_22" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# ingress 80
resource "aws_vpc_security_group_ingress_rule" "mySG_80" {
  security_group_id = aws_security_group.mySG.id # SG ID
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
# ingress 443
resource "aws_vpc_security_group_ingress_rule" "mySG_443" {
  security_group_id = aws_security_group.mySG.id # SG ID
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# egress
resource "aws_vpc_security_group_egress_rule" "mySG_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # 모든 포트 허용
}


#############################
# 2. EC2 생성
#############################
# 1) 키페어 생성 및 설정(mykeypair) - 생성된 키 페어 사용
# 2) EC2 생성
# * 새로 생성된 mySubSN에 EC2를 위치
# * security group(mySG) 포함
# * user_data(80/tcp, 443/tcp) 지정
# => user_data 변경이 되면 EC2 재 생성하도록 설정

# ssh-keygen -t rsa -N "" -f ~/.ssh/mykeypair
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file("~/.ssh/mykeypair.pub")
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "myEC2" {
  # AMI: Amazon linux 2023 ami
  ami           = "ami-00e428798e77d38d9"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.myPubSN.id
  key_name      = "mykeypair"

  # SG 등록, ID 값을 리스트 형태로 등록한다.
  # argument_reference에서 security_group을 서치한다.
  # (Optional, VPC only) List of security group IDs to associate with.
  vpc_security_group_ids = [aws_security_group.mySG.id]

  # user_data를 등록한다.
  # argument_reference에서 user_data를 서치한다.
  # user_data_replace_on_change is set then updates to this field will trigger a destroy and recreate of the EC2 instance.
  # user_data_replace_on_change는 유저데이터의 값이 바뀌면 자동으로 EC2를 업데이트 하는 기능이다.
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    dnf install -y httpd mod_ssl
    echo "My Web Server Test Page" > /var/www/html/index.html
    systemctl enable --now httpd
    EOF

  tags = {
    Name = "myEC2"
  }
}



