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

variable "route53_domain_private" {
  description = "Our private domain"
}

variable "whitelist_monitoring_ips" {
  description = "List of ips allowed to access the monitoring front end"
  type = "list"
}

variable "bastion_remote_state_bucket_name" {
  description = "our remote tf bucket for bastion"
}

variable "short_environment_identifier" {}

variable "public_ssl_arn" {}

variable "route53_hosted_zone_id" {}

variable "project_name" {}

variable "environment_type" {}
