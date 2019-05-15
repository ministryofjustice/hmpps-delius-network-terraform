# S3 Buckets
output "s3_oracledb_backups" {
  value = {
      arn    = "${aws_s3_bucket.oracledb_backups.arn}",
      domain = "${aws_s3_bucket.oracledb_backups.bucket_domain_name}",
      name   = "${aws_s3_bucket.oracledb_backups.id}",
      region = "${var.region}"
    }
}
