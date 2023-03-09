module "backend" {
  source = "../modules/s3_backend"

  dynamodb_table_name = "proactive-devops-engineer-senior-lock-table"
  s3_acl              = "private"
  s3_backend_folder   = "raul-rivera/"
  s3_name             = "proactive-devops-engineer-senior-tfstate"
  tags = {
    Recruit = "Raul Rivera"
  }
}

terraform {
  backend "local" {}
}

provider "aws" {
  region = "us-east-1"
}
