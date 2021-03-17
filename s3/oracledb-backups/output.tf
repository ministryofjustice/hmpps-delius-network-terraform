# S3 Buckets
output "s3_oracledb_backups" {
  value = {
    arn    = aws_s3_bucket.oracledb_backups.arn
    domain = aws_s3_bucket.oracledb_backups.bucket_domain_name
    name   = aws_s3_bucket.oracledb_backups.id
    region = var.region
  }
}

output "s3_oracledb_backups_inventory_s3bucket" {
  value = {
    arn    = aws_s3_bucket.oracledb_backups_inventory_s3bucket.arn
    domain = aws_s3_bucket.oracledb_backups_inventory_s3bucket.bucket_domain_name
    name   = aws_s3_bucket.oracledb_backups_inventory_s3bucket.id
    id     = aws_s3_bucket.oracledb_backups_inventory_s3bucket.id
    region = var.region
  }
}