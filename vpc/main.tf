terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

#-------------------------------------------------------------
### Getting the current running account id
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}

#-------------------------------------------------------------
### Getting the engineering platform vpc
#-------------------------------------------------------------
data "terraform_remote_state" "eng_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    key      = "vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.eng_role_arn}"
  }
}

#-------------------------------------------------------------
### Getting the bastion vpc
#-------------------------------------------------------------
data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${var.bastion_remote_state_bucket_name}"
    key      = "bastion-vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.bastion_role_arn}"
  }
}
