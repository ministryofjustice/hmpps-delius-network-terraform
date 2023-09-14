variable "tiny_environment_identifier" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  description = "The AWS region."
}

variable "oracle_s3_backup_bucket_access" {
  type    = map(list(string))
  default = {modernisation_platform_role_arns = []}
}

variable "short_environment_name" {
  type = string
}