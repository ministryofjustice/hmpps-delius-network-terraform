terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.23"
}

provider "aws" {
  alias = "delius_prod_acct_r53_delegation"
  region  = "${var.region}"
  version = "~> 2.23"
  # Role in delius prod account for managing R53 NS delegation records
  assume_role {
    role_arn = "${var.strategic_parent_zone_delegation_role}"
  }
}