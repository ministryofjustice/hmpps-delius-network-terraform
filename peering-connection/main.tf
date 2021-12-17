#-------------------------------------------------------------
### Getting aws_caller_identity
#-------------------------------------------------------------
data "aws_caller_identity" "current" {
}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the bastion vpc
#-------------------------------------------------------------
data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config = {
    bucket   = var.bastion_remote_state_bucket_name
    key      = "bastion-vpc/terraform.tfstate"
    region   = var.region
    role_arn = var.bastion_role_arn
  }
}

#-------------------------------------------------------------
### Getting the vpn vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpn_remote_vpc" {
  backend = "s3"

  config = {
    bucket   = "tf-eu-west-2-hmpps-bastion-dev-remote-state"
    key      = "vpn-vpc/terraform.tfstate"
    region   = var.region
    role_arn = "arn:aws:iam::895523100917:role/terraform"
  }
}
