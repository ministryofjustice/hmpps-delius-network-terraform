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

module "common-nat-az1" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//natgateway"
  az     = "${var.environment_name}-az1"
  subnet = "${data.terraform_remote_state.vpc.vpc_public-subnet-az1}"
  tags   = "${data.terraform_remote_state.vpc.tags}"
}

module "common-nat-az2" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//natgateway"
  az     = "${var.environment_name}-az2"
  subnet = "${data.terraform_remote_state.vpc.vpc_public-subnet-az2}"
  tags   = "${data.terraform_remote_state.vpc.tags}"
}

module "common-nat-az3" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//natgateway"
  az     = "${var.environment_name}-az3"
  subnet = "${data.terraform_remote_state.vpc.vpc_public-subnet-az3}"
  tags   = "${data.terraform_remote_state.vpc.tags}"
}
