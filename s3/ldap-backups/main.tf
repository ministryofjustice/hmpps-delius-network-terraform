# ### oracledb-backups-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name           = "${var.tiny_environment_identifier}-ldap-backups"
  ldap_config           = merge(var.default_ldap_config, var.ldap_config)
  lambda_name           = "ldap-data-migration-lambda"

  migration_buckets_target = {
    "delius-mis-dev"   = "delius-core-dev-ldap-20230727141945630400000001"
    "delius-test"  = "ldap-test-migration20240131110317239900000004"
  }
}

resource "aws_s3_bucket" "ldap_backups" {
  bucket = local.bucket_name
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
      days = local.ldap_config["backup_retention_days"]
    }
  }

  lifecycle_rule {
    # Old lifecycle rule. Left here to clear out historic LDIF backup files.
    id      = "${local.bucket_name}-expiration"
    enabled = true
    prefix  = "ldap/"
    expiration {
      days = local.ldap_config["backup_retention_days"]
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    var.tags,
    { "Name" = local.bucket_name },
  )
}

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket              = aws_s3_bucket.ldap_backups.id
  block_public_acls   = true
  block_public_policy = true
}

