# ### oracledb-backups-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name = "${var.tiny_environment_identifier}-oracledb-backups"
  inventory_bucket_name = "${var.tiny_environment_identifier}-oracledb-backups-inventory-s3bucket"
  inventory_name = "${var.tiny_environment_identifier}-oracledb-backups-inventory"
}

resource "aws_s3_bucket" "oracledb_backups" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
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


resource "aws_s3_bucket" "oracledb_backups_inventory_s3bucket" {
  bucket = local.inventory_bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = merge(
    var.tags,
    {
      "Name" = local.inventory_bucket_name
    },
    {
      "Purpose" = "Inventory of Oracle DB Backup Pieces"
    },
  )
}
data "aws_caller_identity" "current" {
}
data "template_file" "oracledb_backups_inventory_policy" {
  template = file("./policies/oracledb_backups_inventory.json")

  vars = {
    backup_s3bucket_arn = oracledb_backups.arn
    inventory_s3bucket_arn = oracledb_backups_inventory_s3bucket.arn
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_s3_bucket_inventory" "oracledb_backups_inventory_s3bucket" {
  bucket = aws_s3_bucket.oracledb_backups.id
  name   = "OracleBackupBucketDaily"

  included_object_versions = "Current"

  optional_fields = ["Size","LastModifiedDate"]

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.oracledb_backups_inventory_s3bucket.arn
    }
  }
}