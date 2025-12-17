terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }

  # https://developer.hashicorp.com/terraform/language/backend/s3
  backend "s3" {
    bucket = "mynsh-7979"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "my_tflocks"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

