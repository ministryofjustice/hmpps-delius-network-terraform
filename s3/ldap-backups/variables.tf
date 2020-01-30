variable "tiny_environment_identifier" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "region" {
  description = "The AWS region."
}

variable "ldap_config" {
  type = "map"
  default = {
    backup_retention_days = 90
  }
}
