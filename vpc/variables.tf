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
  type        = "string"
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
# vpc
variable "route53_domain_private" {
  type = "string"
}

variable "aws_nameserver" {
  type = "string"
}

# peering

variable "bastion_account_id" {
  type = "string"
}

variable "bastion_vpc_id" {
  type = "string"
}

### Subnets
variable "public_subnet" {
  type = "string"
}

variable "private_subnet" {
  type = "string"
}

variable "db_subnet" {
  type = "string"
}

variable "az_list" {
  description = "List of the three AZs we want to use"
  type        = "list"
}

variable "availability_zone" {
  type        = "map"
}
