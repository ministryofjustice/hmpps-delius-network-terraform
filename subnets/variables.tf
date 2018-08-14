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

variable "tags" {
  type = "map"
}
