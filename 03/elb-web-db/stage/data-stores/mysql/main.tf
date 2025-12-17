##########################################
# 1. provider 설정
# 2. DB(MySQL) 생성
##########################################


##########################################
# 1. provider 설정
##########################################
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
  # https://developer.hashicorp.com/terraform/language/backend/s3
    backend "s3" {
    bucket = "mynsh-1234" 
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "mylocktable"
    #use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"
}

##########################################
# 2. DB(MySQL) 생성
##########################################
# * username(dbuser)/password(dbpassword)
# * DB name
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.c6gd.medium"
  username             = "${var.dbuser}"
  password             = "${var.dbpassword}"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
# 생성된 내용은 복사해놓는다.
# dynamodb_table_name = "mylocktable"
# s3_bucket_arn = "arn:aws:s3:::mynsh-1234"



