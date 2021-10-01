provider "aws" {
  alias   = "delius_prod_acct_r53_delegation"
  region  = var.region
  version = "~> 3.0"

  # Role in delius prod account for managing R53 NS delegation records
  assume_role {
    role_arn = var.strategic_parent_zone_delegation_role
  }
}

#-------------------------------------------------------------
### Getting the current running account id
#-------------------------------------------------------------
data "aws_caller_identity" "current" {
}

#-------------------------------------------------------------
### Getting the engineering platform vpc
#-------------------------------------------------------------
data "terraform_remote_state" "eng_remote_vpc" {
  backend = "s3"

  config = {
    bucket   = var.eng_remote_state_bucket_name
    key      = "vpc/terraform.tfstate"
    region   = var.region
    role_arn = var.eng_role_arn
  }
}

#-------------------------------------------------------------
### Getting the bastion vpc
#-------------------------------------------------------------
data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config = {
    bucket   = var.bastion_remote_state_bucket_name
    key      = "bastion-vpc/terraform.tfstate"
    region   = var.region
    role_arn = var.bastion_role_arn
  }
}

data "terraform_remote_state" "vpn_remote_vpc" {
  backend = "s3"

  config = {
    bucket   = "tf-eu-west-2-hmpps-bastion-dev-remote-state"
    key      = "vpn-vpc/terraform.tfstate"
    region   = var.region
    role_arn = "arn:aws:iam::895523100917:role/terraform"
  }
}

## Lambda to snapshot volumes periodically

module "create_snapshot_lambda" {
  source           = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ebs-backup?ref=terraform-0.12"
  cron_expression  = "30 1 * * ? *"
  regions          = [var.region]
  rolename_prefix  = var.environment_identifier
  stack_prefix     = var.environment_name
  ec2_instance_tag = "CreateSnapshot"
  unique_name      = "snapshot_ebs_volumes"
  retention_days   = var.snapshot_retention_days
}

