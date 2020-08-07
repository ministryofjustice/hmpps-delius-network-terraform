terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = ">= 2.65"
}

# ### oracledb-backups-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name = "${var.tiny_environment_identifier}-ldap-backups"
  ldap_config = "${merge(var.default_ldap_config, var.ldap_config)}"
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
    id      = "${local.bucket_name}-hourly-expiration"
    enabled = true
    prefix  = "hourly/"
    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    id      = "${local.bucket_name}-daily-expiration"
    enabled = true
    prefix  = "daily/"
    expiration {
      days = "${local.ldap_config["backup_retention_days"]}"
    }
  }

  lifecycle_rule {
    # Old lifecycle rule. Left here to clear out historic LDIF backup files.
    id      = "${local.bucket_name}-expiration"
    enabled = true
    prefix  = "ldap/"
    expiration {
      days = "${local.ldap_config["backup_retention_days"]}"
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

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket              = "${aws_s3_bucket.ldap_backups.id}"
  block_public_acls   = true
  block_public_policy = true
}
