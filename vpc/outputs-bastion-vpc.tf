output "bastion_vpc_account_id" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_account_id}"
}

output "bastion_vpc_id" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_id}"
}

output "bastion_vpc_public_cidr" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_public_cidr}"
}
