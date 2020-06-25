## The configuration for this backend will be filled in by Terragrunt
## it will create these files from ../terragrunt.hcl
## provider.tf
## backend.tf

provider "aws" {
  alias   = "delius_prod_acct_r53_delegation"
  region  = var.region
  version = "~> 2.65"

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

## Lambda to snapshot volumes periodically

module "create_snapshot_lambda" {
  source           = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ebs-backup?ref=ALS-884-TF_12Spike_0.1.0_tf0.12"
  cron_expression  = "30 1 * * ? *"
  regions          = [var.region]
  rolename_prefix  = var.environment_identifier
  stack_prefix     = var.environment_name
  ec2_instance_tag = "CreateSnapshot"
  unique_name      = "snapshot_ebs_volumes"
  retention_days   = var.snapshot_retention_days
}

