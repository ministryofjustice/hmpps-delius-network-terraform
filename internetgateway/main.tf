data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

module "env_igw" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/internetgateway?ref=terraform-0.12"
  gateway_name = var.environment_name
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  tags         = var.tags
}

