variable "environment_name" {
  type = string
}

variable "environment_identifier" {
  type        = string
  description = "resource label or name"
}

variable "tags" {
  type = map(string)
}

variable "region" {
  type        = string
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  type        = string
  description = "Terraform remote state bucket name"
}

variable "short_environment_name" {
}

variable "project_name" {
  type        = string
  description = "Name of the project e.g. delius"
}