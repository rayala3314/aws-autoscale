# Provider configuration
provider "aws" {
  region  = var.region
  version = "~> 3.0"
  profile = "testapp"
}

