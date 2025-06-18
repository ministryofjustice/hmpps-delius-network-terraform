##### IAM User & Resources to access the sqs queue and read cloudtrail and flowlogs query log buckets
resource "aws_iam_user" "cortex_xsiam_user" {
  name = "cortex_xsiam_user"
  path = "/"
}

data "aws_iam_policy_document" "sqs_queue_read_document" {
  statement {
    sid    = "SQSQueueReceiveMessages"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [
      aws_sqs_queue.cloudtrail_logging.arn,
      aws_sqs_queue.vpc_flowlogs_log_queue.arn
    ]
  }
  statement {
    sid     = "SQSReadLoggingS3"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      data.aws_s3_bucket.cloudtrail_logging.arn,
      "${data.aws_s3_bucket.cloudtrail_logging.arn}/*",
      aws_s3_bucket.flow_logs.arn,
      "${aws_s3_bucket.flow_logs.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "sqs_queue_read_policy" {
  name        = "sqs-queue-read-policy"
  description = "Allows the access to the created SQS queue"
  policy      = data.aws_iam_policy_document.sqs_queue_read_document.json
}

resource "aws_iam_user_policy_attachment" "sqs_queue_read_policy_attachment" {
  user       = "cortex_xsiam_user"
  policy_arn = aws_iam_policy.sqs_queue_read_policy.arn
}