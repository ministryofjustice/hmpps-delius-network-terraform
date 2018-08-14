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

variable "az_list" {
  description = "List of the availability zones to create the routes in"
  type        = "list"
}

variable "tags" {
  type = "map"
}
