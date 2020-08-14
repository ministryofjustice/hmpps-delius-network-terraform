#-------------------------------------------------------------
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the vpc details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

locals {
  app_name             = "auto-start"
  internal_domain      = data.terraform_remote_state.vpc.outputs.private_zone_name
  sg_bastion_in        = data.terraform_remote_state.security-groups.outputs.sg_ssh_bastion_in_id
  sg_https_out         = data.terraform_remote_state.security-groups.outputs.sg_https_out
  ec2_policy_file      = "ec2_policy.json"
  ec2_role_policy_file = "policies/ec2.json"
  tags = merge(
    var.tags,
    {
      "autostop-${var.environment_type}" = "Phase1"
    },
  )
}

