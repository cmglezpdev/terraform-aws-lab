terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "terraform-custom-projects"
      Stack     = "02-lambda-retry"
      ManagedBy = "terraform"
    }
  }
}