############################################
# KMS KEY GENERATION - FOR ENCRYPTION
############################################

module "kms_key" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/kms?ref=terraform-0.12-pre-shared-vpc"
  kms_key_name = local.common_name
  tags         = local.tags
}

