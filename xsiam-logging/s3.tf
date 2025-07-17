# Bucket to host manually-uploaded agent tars
resource "aws_s3_bucket" "xsiam_bucket" {
  bucket = local.xsiam_bucket
  acl    = "private"

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags,
    { "Name" = local.xsiam_bucket },
  )
}

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket              = aws_s3_bucket.xsiam_bucket.id
  block_public_acls   = true
  block_public_policy = true
}

