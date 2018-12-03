output "bastion_vpc_account_id" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_account_id}"
}

output "bastion_vpc_id" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_id}"
}

output "bastion_vpc_public_cidr" {
  value = "${data.terraform_remote_state.bastion_remote_vpc.bastion_public_cidr}"
}

output "bastion_role_arn" {
  value = "${var.bastion_role_arn}"
}

output "bastion_remote_state_bucket_name" {
  value = "${var.bastion_remote_state_bucket_name}"
}