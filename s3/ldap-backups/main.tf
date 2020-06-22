terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.65"
}

# ### oracledb-backups-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name = "${var.tiny_environment_identifier}-ldap-backups"
}


resource "aws_s3_bucket" "ldap_backups" {
  bucket = "${local.bucket_name}"
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "${local.bucket_name}-expiration"
    enabled = true
    prefix  = "ldap/"
    expiration {
      days = "${var.ldap_config["backup_retention_days"]}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(var.tags, map("Name", "${local.bucket_name}"))}"
}
