variable "tiny_environment_identifier" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  description = "The AWS region."
}

variable "default_ldap_config" {
  description = "Default values to be overridden by ldap_config"
  type        = map(string)
}

variable "ldap_config" {
  description = "LDAP configuration"
  type        = map(string)
}

