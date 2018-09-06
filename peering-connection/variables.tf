variable "environment_name" {
  type = "string"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "eng_remote_state_bucket_name" {
  description = "Terraform remote state bucket name for engineering platform vpc"
}

variable "bastion_remote_state_bucket_name" {
  description = "Terraform remote state bucket name for bastion vpc"
}

variable "eng_role_arn" {
  description = "arn to use for engineering platform terraform"
}

variable "bastion_role_arn" {
  description = "arn to use for bastion terraform"
}
