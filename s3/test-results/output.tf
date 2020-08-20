# S3 Buckets
output "s3_test_results" {
  value = {
    arn    = aws_s3_bucket.test_results.arn
    domain = aws_s3_bucket.test_results.bucket_domain_name
    name   = aws_s3_bucket.test_results.id
    region = var.region
  }
}

