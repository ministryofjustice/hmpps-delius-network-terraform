variable "remote_state_bucket_name" {}

variable "region" {}

variable "environment_type" {}

variable "environment_name" {}

variable "bastion_inventory" {
  default = "dev"
}

variable "short_environment_identifier" {}

variable "tags" {
  type = "map"
}

variable "instance_type" {
  default = "t2.small"
}
