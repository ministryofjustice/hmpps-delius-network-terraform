variable "environment_name" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "vpc_supernet" {
  description = "Supernet for the whole VPC that all subnets will be in"
  type        = "string"
}

variable "role_arn" {
  type = "string"
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name for the sub vpc (ie sandpit2, sandpit3)"
}

variable "network_and_legacy_spg_remote_state_bucket_name" {
  default="n/a"
  description = "Terraform remote state bucket name for the parent vpc (ie sandpit)"
}


variable "region" {
  description = "AWS Region"
  type        = "string"
}

variable "project_name" {
  description = "The project name - delius-core"
  type        = "string"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
  type        = "string"
}

variable "bastion_inventory" {
  description = "The bastion inventory eg dev"
  type        = "string"
}

## remote states
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

# vpc
variable "route53_domain_private" {
  type = "string"
}

variable "public_dns_parent_zone" {
  type = "string"
  description = "for strategic .gov domain. set in common.properties"
}

variable "public_dns_child_zone" {
  type = "string"
  description = "for strategic .gov domain. set in common.properties."
}




variable "aws_nameserver" {
  type = "string"
}

variable "availability_zone" {
  description = "List of the three AZs we want to use"
  type = "map"
}

variable "environment_identifier" {}

variable "subdomain" {}

variable "snapshot_retention_days" {}


# Variables to support managing strategic (*.probation.service.justice.gov.uk) delegation records in the production account parent R53 zone
variable "strategic_parent_zone_delegation_role" {
  description = "Cross account IAM Role ARN in Prod Acct for assuming and managing strategic domain delegation (NS) records"
}

variable "strategic_parent_zone_id" {
  description = "Parent R53 Zone ID for strategic domain (probation.service.justice.gov.uk)"
}