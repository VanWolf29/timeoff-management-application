variable "s3_name" {
  description = "Terraform S3 backend name"
  type        = string
}

variable "s3_acl" {
  description = "ACL for terraform S3 backend"
  type        = string
}

variable "s3_force_destroy" {
  description = "Whether to force destruction of S3 bucket"
  default     = true
  type        = bool
}

variable "s3_backend_folder" {
  description = "Folder where terraform state will live"
  type        = string
}

variable "tags" {
  description = "Tags for Terraform S3 and dynamodb table"
  type        = map(string)
}

variable "dynamodb_table_name" {
  description = "Name of the state lock table"
  type        = string
}

variable "dynamodb_table_rcu" {
  description = "Read capacity units for state lock table"
  type        = number
  default     = 5
}

variable "dynamodb_table_wcu" {
  description = "Write capacity units for state lock table"
  type        = number
  default     = 5
}
