# Provider configuration
required_providers "aws" {
  region  = var.region
  version = "~> 3.0"
  profile = "testapp"
}

# Use data sources allow configuration to be
# generic for any region
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}