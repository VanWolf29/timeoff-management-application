terraform {
  backend "s3" {
    bucket         = "roactive-devops-engineer-senior-tfstate"
    encrypt        = true
    key            = "raul-rivera/"
    region         = "us-east-1"
    dynamodb_table = "proactive-devops-engineer-senior-lock-table"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.1"
    }
  }
  required_version = ">= 1.3.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
