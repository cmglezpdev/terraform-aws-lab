terraform {
  backend "s3" {
    bucket = "tf-state-learning-course-terraform"
    key    = "01-serverless-api/terraform.tfstate"
    region = "us-east-1"

    encrypt      = true
    use_lockfile = true
  }
}