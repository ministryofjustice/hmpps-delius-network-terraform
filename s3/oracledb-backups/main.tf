# ### oracledb-backups-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name = "${var.tiny_environment_identifier}-oracledb-backups"
  inventory_bucket_name = "${var.tiny_environment_identifier}-oracledb-backups-inventory"
  inventory_name = "${var.tiny_environment_identifier}-oracledb-backuppieces"
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

# S3 Bucket Permission Policy From Modernisation platform

data "template_file" "oracledb_backups_policy_file" {
  template = file("./policies/oracledb_backups.json")
  vars = {
    backup_s3bucket_arn              = aws_s3_bucket.oracledb_backups.arn
    modernisation_platform_role_arns = trimsuffix(trimprefix(join(",",formatlist("\"%s\"",var.oracle_s3_backup_bucket_access.modernisation_platform_role_arns)),"\""),"\"")
  }
}

resource "aws_s3_bucket_policy" "oracledb_backups_policy" {
  count  = length(var.oracle_s3_backup_bucket_access.modernisation_platform_role_arns) > 0 ? 1: 0
  bucket = aws_s3_bucket.oracledb_backups.id
  policy = data.template_file.oracledb_backups_policy_file.rendered
}

resource "aws_s3_bucket" "oracledb_backups_inventory" {
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
data "template_file" "oracledb_backups_inventory_policy_file" {
  template = file("./policies/oracledb_backups_inventory.json")

  vars = {
    backup_s3bucket_arn = aws_s3_bucket.oracledb_backups.arn
    inventory_s3bucket_arn = aws_s3_bucket.oracledb_backups_inventory.arn
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_s3_bucket_policy" "oracledb_backups_inventory_policy" {
  bucket = aws_s3_bucket.oracledb_backups_inventory.id

  policy = data.template_file.oracledb_backups_inventory_policy_file.rendered
}

resource "aws_s3_bucket_inventory" "oracledb_backuppieces" {
  bucket = aws_s3_bucket.oracledb_backups.id
  name   = local.inventory_name

  included_object_versions = "Current"

  optional_fields = ["Size","LastModifiedDate"]

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.oracledb_backups_inventory.arn
    }
  }
}