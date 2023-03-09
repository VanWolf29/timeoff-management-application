resource "aws_s3_bucket" "tfstate" {
  bucket        = var.s3_name
  acl           = var.s3_acl
  force_destroy = var.s3_force_destroy

  tags = merge(var.tags, { Name = var.s3_name })
}

resource "aws_s3_bucket_object" "tfstate_folder" {
  bucket = aws_s3_bucket.tfstate.id
  key    = var.s3_backend_folder
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = var.dynamodb_table_name
  read_capacity  = var.dynamodb_table_rcu
  write_capacity = var.dynamodb_table_wcu
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, { "Name" = var.dynamodb_table_name })
}
