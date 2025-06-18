#### Cloudtrail
data "aws_s3_bucket" "cloudtrail_logging" {
  bucket = local.cloudtrail_bucket
}

resource "aws_sqs_queue" "cloudtrail_logging" {
  name                       = "cloudtrail_log_queue"
  sqs_managed_sse_enabled    = true   # Using managed encryption
  delay_seconds              = 0      # The default is 0 but can be up to 15 minutes
  max_message_size           = 262144 # 256k which is the max size
  message_retention_seconds  = 345600 # This is 4 days. The max is 14 days
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.cloudtrail_logging.id
  policy    = data.aws_iam_policy_document.queue_policy_document.json
}

data "aws_iam_policy_document" "queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.cloudtrail_logging.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.cloudtrail_logging.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "cloudtrail_logging" {
  bucket = data.aws_s3_bucket.cloudtrail_logging.id
  queue {
    queue_arn = aws_sqs_queue.cloudtrail_logging.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}
