data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

# ssm parameter
data "aws_ssm_parameter" "ssm_token" {
  name = var.acm_alerts_info["slack_ssm_token"]
}

locals {
  acm_alerts_info = var.acm_alerts_info
  function_name   = "acm_alerts_handler"
  tags            = data.terraform_remote_state.vpc.outputs.tags
  log_group       = "/aws/lambda/${local.function_name}"
  ssm_token_arn   = data.aws_ssm_parameter.ssm_token.arn
}
