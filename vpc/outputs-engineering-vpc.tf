output "eng_vpc_account_id" {
  value = "${data.terraform_remote_state.eng_remote_vpc.account_id}"
}

output "eng_vpc_id" {
  value = "${data.terraform_remote_state.eng_remote_vpc.vpc_id}"
}

output "eng_vpc_cidr" {
  value = "${data.terraform_remote_state.eng_remote_vpc.vpc_cidr}"
}
