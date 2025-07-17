#### AWS Config
data "aws_s3_bucket" "aws_config" {
  bucket = local.aws_config_bucket
}

resource "aws_sqs_queue" "aws_config" {
  name                       = "${var.environment_name}-aws-config-queue"
  sqs_managed_sse_enabled    = true   
  delay_seconds              = 0      
  max_message_size           = 262144 
  message_retention_seconds  = 345600 
  visibility_timeout_seconds = 30     
}

resource "aws_sqs_queue_policy" "aws_config_queue_policy" {
  queue_url = aws_sqs_queue.aws_config.id
  policy    = data.aws_iam_policy_document.aws_config_queue_policy_document.json
}

data "aws_iam_policy_document" "aws_config_queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.aws_config.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.aws_config.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "aws_config_bucket_notification" {
  bucket = data.aws_s3_bucket.aws_config.id
  queue {
    queue_arn = aws_sqs_queue.aws_config.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}