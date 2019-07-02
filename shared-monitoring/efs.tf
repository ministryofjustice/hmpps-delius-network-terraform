####################################################
# EFS content
####################################################
module "efs_backups" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//efs"
  environment_identifier = "${local.short_environment_identifier}"
  tags                   = "${local.tags}"
  encrypted              = true
  kms_key_id             = "${module.kms_key.kms_arn}"
  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  share_name             = "elk-fs"
  zone_id                = "${local.private_zone_id}"
  domain                 = "${local.internal_domain}"
  subnets                = "${local.private_subnet_ids}"
  security_groups        = ["${local.efs_security_groups}"]
}
