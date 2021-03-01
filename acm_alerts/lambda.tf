resource "aws_cloudwatch_log_group" "lambda" {
  name              = local.log_group
  retention_in_days = var.cloudwatch_log_retention
  tags              = local.tags
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid = "sts"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = local.common_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  description        = local.function_name
  tags               = local.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "Generic"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "acm:ListCertificates",
      "acm:DescribeCertificate"
    ]

    resources = [
      "*",
    ]
  }
  statement {
    sid = "SSM"

    actions = [
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*"
    ]

    resources = [
      local.ssm_token_arn,
    ]
  }
}

resource "aws_iam_role_policy" "lambda" {
  name   = local.common_name
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "lambda" {
  s3_bucket     = local.acm_alerts_info["bucket"]
  s3_key        = "${local.acm_alerts_info["s3Key"]}/${local.function_name}/function.zip"
  function_name = local.common_name
  role          = aws_iam_role.lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  publish       = true
  memory_size   = 256
  timeout       = 30

  environment {
    variables = {
      ENABLE_SSL_CONTEXT  = 0
      ENVIRONMENT_NAME    = var.environment_name
      SLACK_API_TOKEN_SSM = local.acm_alerts_info["slack_ssm_token"]
      SLACK_CHANNEL_NAME  = local.acm_alerts_info["slack_channel"]
      SSL_BUFFER_DAYS     = local.acm_alerts_info["buffer_days"]
    }
  }
  tags = merge(
    local.tags,
    {
      "Name" = local.common_name
    },
  )
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = local.common_name
  description         = "Scheduled Cloudwatch Event for ${local.function_name}"
  schedule_expression = local.acm_alerts_info["schedule_expression"]
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda.name
  target_id = aws_lambda_function.lambda.id
  arn       = aws_lambda_function.lambda.arn
}
