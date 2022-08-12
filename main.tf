# Require TF version to be same as or greater than 0.12.13
terraform {
  required_providers{
    aws = {
      source = "hasicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-west-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.0.0/20"
  availability_zone = "us-west-1a"
  
}