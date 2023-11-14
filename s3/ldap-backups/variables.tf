variable "tiny_environment_identifier" {
  type = string
}

variable "environment_name" {
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

variable "ldap_migration_bucket_name" {
  description = "S3 bucket name where ldap data is transferred to. This bucket is created in the Mod Platform account"
  type        = map(string)
  default     = {
    delius-mis-dev = "delius-core-dev-ldap-20230727141945630400000001"
  }
}
