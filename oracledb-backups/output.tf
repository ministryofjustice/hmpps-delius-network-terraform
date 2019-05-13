# S3 Buckets
output "oracledb_backups_s3bucket" {
  value = {
      arn    = "${aws_s3_bucket.oracledb_backups.arn}",
      domain = "${aws_s3_bucket.oracledb_backups.bucket_domain_name}",
      name   = "${aws_s3_bucket.oracledb_backups.id}",
      region = "${var.region}"
    }
}
