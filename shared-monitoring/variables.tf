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

variable "whitelist_monitoring_ips" {
  description = "List of ips allowed to access the monitoring front end"
  type = "list"
}

variable "short_environment_identifier" {}

variable "project_name" {}

variable "environment_type" {}

variable "bastion_inventory" {}
