variable "environment_name" {
  type = "string"
}

variable "tags" {
  type = "map"
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

variable "route53_domain_private" {
  description = "Our private domain"
}

variable "short_environment_identifier" {}

variable "project_name" {}

variable "environment_type" {}

variable "bastion_inventory" {}

variable "project_name_abbreviated" {
  description = "Shortened environment name"
}
