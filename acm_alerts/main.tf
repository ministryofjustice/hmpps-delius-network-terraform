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
  acm_alerts_info = merge(var.acm_alerts_info, var.acm_alerts_config)
  function_name   = "acm_alerts_handler"
  common_name     = "${var.short_environment_name}_${local.function_name}"
  tags            = data.terraform_remote_state.vpc.outputs.tags
  log_group       = "/aws/lambda/${local.common_name}"
  ssm_token_arn   = data.aws_ssm_parameter.ssm_token.arn
}
