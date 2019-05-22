# --------------------------------
# Terraform configuration

terraform {
  required_version = "0.11.14"

  required_providers {
    aws = "2.10"
  }

  backend "s3" {
    region = "us-east-1"
    key    = "terraform/state"
  }
}

provider "aws" {
  region = "us-east-1"

  #assume_role {
  #  role_arn = "arn:aws:iam::${var.aws_account_id}:role/AssumeRoleTerraform"
  #}
}
