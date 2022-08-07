# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-west-1"
  version = "~> 2.36.0"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}