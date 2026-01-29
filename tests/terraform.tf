# Terraform Test Configuration

terraform {
  required_version = ">= 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Test provider configuration
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Test = "terraform-aws-s3-permissions"
    }
  }
}