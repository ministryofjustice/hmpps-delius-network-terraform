terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

############################
# DATA
############################
#-------------------------------------------------------------
### Getting aws_caller_identity
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "eng_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    key      = "vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.eng_role_arn}"
  }
}

data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${var.bastion_remote_state_bucket_name}"
    key      = "bastion-vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.bastion_role_arn}"
  }
}
