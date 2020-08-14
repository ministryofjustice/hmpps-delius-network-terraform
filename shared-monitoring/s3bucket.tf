#-------------------------------------------
### S3 bucket for logs
#--------------------------------------------
module "s3_lb_logs_bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/s3bucket/s3bucket_without_policy?ref=terraform-0.12-pre-shared-vpc"
  s3_bucket_name = "${local.common_name}-lb-logs"
  tags           = local.tags
}

#-------------------------------------------
### Attaching S3 bucket policy to ALB logs bucket
#--------------------------------------------

data "template_file" "s3alb_logs_policy" {
  template = file(var.s3_lb_policy_file)

  vars = {
    s3_bucket_name   = module.s3_lb_logs_bucket.s3_bucket_name
    s3_bucket_prefix = "${local.short_environment_identifier}-*"
    aws_account_id   = data.aws_caller_identity.current.account_id
    lb_account_id    = var.lb_account_id
  }
}

module "s3alb_logs_policy" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/s3bucket/s3bucket_policy?ref=terraform-0.12-pre-shared-vpc"
  s3_bucket_id = module.s3_lb_logs_bucket.s3_bucket_name
  policyfile   = data.template_file.s3alb_logs_policy.rendered
}

#-------------------------------------------
### S3 bucket for backups
#--------------------------------------------

locals {
  transition_days = var.elk_backups_config["transition_days"]
  expiration_days = var.elk_backups_config["expiration_days"]
}

resource "aws_s3_bucket" "backups" {
  bucket = "${local.common_name}-s3bucket"
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.kms_key.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expiration_days
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-s3-bucket"
    },
  )
}

