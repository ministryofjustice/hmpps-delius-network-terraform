#### VPC Flowlogs
resource "aws_s3_bucket" "flow_logs" {
  bucket = "${var.environment_name}-vpc-flow-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket                  = aws_s3_bucket.flow_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_vpc" "vpc" {
    filter {
        name = "tag:Name"
        values = ["${var.environment_name}-vpc"]
    }
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = data.aws_vpc.vpc.id
  log_format           = local.vpc_log_format
}

resource "aws_sqs_queue" "vpc_flowlogs_log_queue" {
  name                       = "${var.environment_name}-vpc-flowlogs-log-queue"
  sqs_managed_sse_enabled    = true   # Using managed encryption
  delay_seconds              = 0      # The default is 0 but can be up to 15 minutes
  max_message_size           = 262144 # 256k which is the max size
  message_retention_seconds  = 345600 # This is 4 days. The max is 14 days
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
}

resource "aws_sqs_queue_policy" "vpc_flowlogs_queue_policy" {
  queue_url = aws_sqs_queue.vpc_flowlogs_log_queue.id
  policy    = data.aws_iam_policy_document.vpc_flowlogs_queue_policy_document.json
}

data "aws_iam_policy_document" "vpc_flowlogs_queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.vpc_flowlogs_log_queue.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.flow_logs.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "vpc_flowlogs_bucket_notification" {
  bucket = aws_s3_bucket.flow_logs.id
  queue {
    queue_arn = aws_sqs_queue.vpc_flowlogs_log_queue.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}