#---------------------------------------------------------------------------------------------------------
#       Resources configured for data migration from legacy pre-prod S3 bucket to ModPlatform S3 bucket
#---------------------------------------------------------------------------------------------------------
# IAM role for Lambda function in the source account
resource "aws_iam_role" "lambda_role" {

  name               = "${local.lambda_name}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# IAM policy for Lambda function in the source account
resource "aws_iam_policy" "lambda_policy" {

  name        = "${local.lambda_name}-policy"
  description = "Policy for Lambda function in the source account"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SourceS3BucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}/*",
                "arn:aws:s3:::${local.bucket_name}"
            ]
        },
        {
            "Sid": "DestS3BucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${lookup(local.migration_buckets_target, var.environment_name)}/*"
        }
    ]
}
EOF
}

# Attach the IAM policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function in the source account
data "archive_file" "data_transfer_lambda" {
  type        = "zip"
  source_file = "${path.module}/${local.lambda_name}/${local.lambda_name}.py"
  output_path = "${path.module}/files/${local.lambda_name}.zip"
}

resource "aws_lambda_function" "data_transfer_lambda" {

  filename      = data.archive_file.data_transfer_lambda.output_path
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "${local.lambda_name}.handler"
  runtime       = "python3.8"
  memory_size   = 5120
  timeout       = 300
  source_code_hash = data.archive_file.data_transfer_lambda.output_base64sha256

  # Environment variables
  environment {
    variables = {
      SOURCE_BUCKET      = local.bucket_name
      SOURCE_PREFIX      = "migration/"
      DESTINATION_BUCKET = local.migration_bucket_name
      DESTINATION_FOLDER = "migration/"
      LOG_LEVEL          = "INFO"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_transfer_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ldap_backups.arn
}

# S3 event notification to trigger the Lambda function in the source account
resource "aws_s3_bucket_notification" "bucket_notification" {

  bucket = aws_s3_bucket.ldap_backups.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.data_transfer_lambda.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*"
    ]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# CloudWatch Log Group to store the logs generated by the Lambda function.
resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {

  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 30
  tags = merge(
    var.tags,
    {
      "Name" = "/aws/lambda/${local.lambda_name}"
    },
  )
}
