variable "environment_name" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "AWS Region"
  type        = "string"
}
