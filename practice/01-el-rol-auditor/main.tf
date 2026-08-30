
terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "tf-state-learning-course-terraform"
    key    = "practice/01-el-rol-auditor/terraform.tfstate"
    region = "us-east-1"

    encrypt      = true
    use_lockfile = true
  }
}


provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "terraform-course"
      Stack     = "01-el-rol-auditor"
      ManagedBy = "terraform"
    }
  }
}