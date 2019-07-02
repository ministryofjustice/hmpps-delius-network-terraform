#-------------------------------------------
### S3 bucket for logs
#--------------------------------------------
module "s3_lb_logs_bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//s3bucket//s3bucket_without_policy"
  s3_bucket_name = "${local.common_name}-lb-logs"
  tags           = "${local.tags}"
}

#-------------------------------------------
### Attaching S3 bucket policy to ALB logs bucket
#--------------------------------------------

data "template_file" "s3alb_logs_policy" {
  template = "${file("${var.s3_lb_policy_file}")}"

  vars {
    s3_bucket_name   = "${module.s3_lb_logs_bucket.s3_bucket_name}"
    s3_bucket_prefix = "${local.short_environment_identifier}-*"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    lb_account_id    = "${var.lb_account_id}"
  }
}

module "s3alb_logs_policy" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//s3bucket//s3bucket_policy"
  s3_bucket_id = "${module.s3_lb_logs_bucket.s3_bucket_name}"
  policyfile   = "${data.template_file.s3alb_logs_policy.rendered}"
}

#-------------------------------------------
### S3 bucket for logs
#--------------------------------------------
module "s3_backups_bucket" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//s3bucket//s3bucket_kms_encryption"
  s3_bucket_name    = "${local.common_name}-backups"
  kms_master_key_id = "${module.kms_key.kms_key_id}"
  tags              = "${local.tags}"
}
