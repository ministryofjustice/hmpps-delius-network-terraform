terraform {
  # # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.60"
}

provider "template" {
  version = "~>2.1.2"
}
