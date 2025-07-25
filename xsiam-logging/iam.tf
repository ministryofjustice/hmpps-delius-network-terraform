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
      aws_sqs_queue.vpc_flowlogs_log_queue.arn,
      aws_sqs_queue.aws_config.arn,
      aws_sqs_queue.loadbalancer.arn
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
      "${aws_s3_bucket.flow_logs.arn}/*",
      data.aws_s3_bucket.aws_config.arn,
      "${data.aws_s3_bucket.aws_config.arn}/*",
      data.aws_s3_bucket.loadbalancer.arn,
      "${data.aws_s3_bucket.loadbalancer.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "sqs_queue_read_policy" {
  name        = "sqs-queue-read-policy"
  description = "Allows the access to the created SQS queue"
  policy      = data.aws_iam_policy_document.sqs_queue_read_document.json
}

resource "aws_iam_user_policy_attachment" "sqs_queue_read_policy_attachment" {
  user       = aws_iam_user.cortex_xsiam_user.name
  policy_arn = aws_iam_policy.sqs_queue_read_policy.arn
}

resource "aws_iam_user_policy_attachment" "securityhub_readonly" {
  user       = aws_iam_user.cortex_xsiam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecurityHubReadOnlyAccess"
}

# Enable ASG instances to access the XSIAM S3 bucket
data "aws_iam_role" "ecs_asg" {
  name = "del-delius-ecshost-private-iam"
}

resource "aws_iam_policy" "ecs_xsiam_access_policy" {
  name        = "del-ecshost-xsiam-s3-read-access"
  description = "Allow read-only access to the xsiam S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.xsiam_bucket.arn,
          "${aws_s3_bucket.xsiam_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_xsiam_s3_policy" {
  role       = data.aws_iam_role.ecs_asg.id
  policy_arn = aws_iam_policy.ecs_xsiam_access_policy.arn
}