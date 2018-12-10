terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

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

#-------------------------------------------------------------
### Getting the bastion vpc
#-------------------------------------------------------------
data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${data.terraform_remote_state.vpc.bastion_remote_state_bucket_name}"
    key      = "bastion-vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${data.terraform_remote_state.vpc.bastion_role_arn}"
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

locals {
  availability_zones      = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-availability_zone}",
  ]
  private_subnet_ids      = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}"
  ]

  private_cidr_blocks     = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az3-cidr_block}"
  ]
  bastion_origin_sgs      = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}"
  ]

  instance_type           = "t2.large"
  ebs_device_volume_size  = "2048"
  route53_sub_domain      = "${var.environment_type}.${var.project_name}"
  account_id              = "${data.aws_caller_identity.current.account_id}"
  public_ssl_arn          = "${data.terraform_remote_state.vpc.public_ssl_arn}"
}

module "nfs-server" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=nfsModule//modules/nfs-server"

  region                        = "${var.region}"
  remote_state_bucket_name      = "${var.remote_state_bucket_name}"
  environment_identifier        = "${var.environment_identifier}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  tags                          = "${var.tags}"
  availability_zones            = "${local.availability_zones}"
  private_subnet_ids            = "${local.private_subnet_ids}"
  instance_type                 = "${local.instance_type}"
  nfs_volume_size               = "${local.ebs_device_volume_size}"

  bastion_origin_sgs            = "${local.bastion_origin_sgs}"
  bastion_inventory             = "${var.bastion_inventory}"

  private-cidr                  = "${local.private_cidr_blocks}"
  route53_sub_domain            = "${local.route53_sub_domain}"
}

