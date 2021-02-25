variable "environment_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "acm_alerts_info" {
  type = map(string)
  default = {
    bucket              = "hmpps-eng-builds-artefact"
    s3Key               = "lambda/eng-lambda-functions-builder/builds/0.0.2"
    slack_channel       = "delius-aws-sec-alerts"
    slack_ssm_token     = "/alfresco/slack/token"
    buffer_days         = "45" #https://docs.aws.amazon.com/acm/latest/userguide/check-certificate-renewal-status.html
    schedule_expression = "rate(7 days)"
  }
}

variable "cloudwatch_log_retention" {
  default = 14
}
