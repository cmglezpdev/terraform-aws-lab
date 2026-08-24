terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"

  # this is applied automatically to EVERY resource that support tags
  default_tags {
    tags = {
      Project   = "terraform-course"
      Stack     = "00-foundations"
      ManagedBy = "terraform"
    }
  }
}
