variable "remote_state_bucket_name" {}

variable "region" {}

variable "environment_type" {}

variable "environment_name" {}

variable "bastion_inventory" {}

variable "short_environment_identifier" {}

variable "tags" {
  type     = "map"
}

variable "instance_type" {
  default  = "t2.large"
}

variable "short_environment_name" {}

variable "instance_count" {
  default  = "1"
}
