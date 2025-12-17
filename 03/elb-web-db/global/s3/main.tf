##########################################
# 1. provider 설정
# 2. S3 mubucket 생성
# 3. DynamoDB Table 생성(Lock ID)
##########################################

##########################################
# 1. provider 설정
##########################################
provider "aws" {
  region = "us-east-2"
}

##########################################
# 2. S3 mubucket 생성
##########################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "mytfstate" {
  bucket = "mynsh-1234"

  tags = {
    Name        = "mytfstate"
  }
}

# 안쓴다는데
##########################################
# 3. DynamoDB Table 생성(Lock ID)
##########################################
# * S3 bucket ARN -> output
# * DynamoDB table name -> output
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
# resource "aws_dynamodb_table" "mylocktable" {
#   name           = "mylocktable"
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Name        = "mylocktable"
#   }
# }
