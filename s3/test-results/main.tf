# ### test-results-s3bucket
# S3 Bucket name will have
# "region-environment_name" prepended

locals {
  bucket_name = "${var.tiny_environment_identifier}-test_results"
}

resource "aws_s3_bucket" "test_results" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags,
    { "Name" = local.bucket_name },
  )
}

