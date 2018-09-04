terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11"
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

locals {
  environment_name = "${var.project_name}-${var.environment_type}"
}

#-------------------------------------------------------------
### Getting the current running account id
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}
