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

module "create_monitoring_cluster" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=esBackups//modules//monitoring"

  remote_state_bucket_name      = "${var.remote_state_bucket_name}"
  environment_type              = "${var.environment_type}"
  project_name                  = "${var.project_name}"
  share_name                    = "${var.short_environment_identifier}_monitoring_backup"
  tags                          = "${var.tags}"
  bastion_inventory             =  "${var.bastion_inventory}"
  whitelist_monitoring_ips      = "${var.whitelist_monitoring_ips}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  environment_identifier        = "${var.environment_identifier}"
  region                        = "${var.region}"
  route53_domain_private        = "${var.route53_domain_private}"
}
