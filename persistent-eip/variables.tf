variable "environment_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "AWS Region"
  type        = string
}

