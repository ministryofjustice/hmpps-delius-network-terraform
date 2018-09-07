terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

module "env_igw" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//internetgateway"
  gateway_name = "${var.environment_name}"
  vpc_id       = "${data.terraform_remote_state.vpc.vpc_id}"
  tags         = "${data.terraform_remote_state.vpc.tags}"
}
