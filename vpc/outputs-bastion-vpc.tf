output "bastion_vpc_account_id" {
  value = data.terraform_remote_state.bastion_remote_vpc.outputs.bastion_vpc_account_id
}

output "bastion_vpc_id" {
  value = data.terraform_remote_state.bastion_remote_vpc.outputs.bastion_vpc_id
}

output "bastion_vpc_public_cidr" {
  value = data.terraform_remote_state.bastion_remote_vpc.outputs.bastion_public_cidr
}

output "bastion_role_arn" {
  value = var.bastion_role_arn
}

output "bastion_remote_state_bucket_name" {
  value = var.bastion_remote_state_bucket_name
}

output "vpn_vpc_cidr" {
  value = data.terraform_remote_state.vpn_remote_vpc.outputs.vpc["cidr"]
}
