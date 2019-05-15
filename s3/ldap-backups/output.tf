# S3 Buckets
output "s3_ldap_backups" {
  value = {
      arn    = "${aws_s3_bucket.ldap_backups.arn}",
      domain = "${aws_s3_bucket.ldap_backups.bucket_domain_name}",
      name   = "${aws_s3_bucket.ldap_backups.id}",
      region = "${var.region}"
    }
}
