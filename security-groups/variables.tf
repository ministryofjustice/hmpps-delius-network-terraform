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

# Alfresco vars
variable "alfresco_app_name" {
  description = "label for Alfresco"
  default     = "alfresco_app_name"
}

# SPG vars
variable "spg_app_name" {
  description = "label for spg"
  default     = "spg"
}

variable "jenkins_access_cidr_blocks" {
  description = "CIDRS for Jenkins to access"
  type        = "list"
}

# MIS vars
variable "mis_app_name" {
  description = "label for spg"
  default     = "mis"
}

# IAPS vars
variable "iaps_app_name" {
  description = "label for IAPS"
  default     = "iaps"
}
