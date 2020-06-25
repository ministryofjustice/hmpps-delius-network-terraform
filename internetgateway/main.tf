## The configuration for this backend will be filled in by Terragrunt
## it will create these files from ../terragrunt.hcl
## provider.tf
## backend.tf

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

module "env_igw" {
  source       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/internetgateway?ref=ALS-884-TF_12Spike_0.1.0_tf0.12"
  gateway_name = "${var.environment_name}"
  vpc_id       = "${data.terraform_remote_state.vpc.vpc_id}"
  tags         = "${var.tags}"
}
