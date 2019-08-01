terraform {
  # # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.4.0"
}

provider "template" {
  version = "~>2.1.2"
}
