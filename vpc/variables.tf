variable "tags" {
  type = "map"
}

variable "vpc_supernet" {
  description = "Supernet for the whole VPC that all subnets will be in"
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

variable "bastion_account_id" {
  type = "string"
}

variable "bastion_vpc_id" {
  type = "string"
}
