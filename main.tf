provider "aws" {}

terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws = ">= 2.11.0"
  }
}
