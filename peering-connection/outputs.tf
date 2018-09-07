output "peering_bastion_vpc_accept_status" {
  value = "${aws_vpc_peering_connection.peering-bastion-vpc.accept_status}"
}

output "peering_bastion_vpc_id" {
  value = "${aws_vpc_peering_connection.peering-bastion-vpc.id}"
}

output "peering_bastion_vpc_id_string" {
  value = "${aws_vpc_peering_connection.peering-bastion-vpc.id},${data.terraform_remote_state.vpc.vpc_cidr_block},${var.environment_name}"
}

output "peering_eng_vpc_accept_status" {
  value = "${aws_vpc_peering_connection.peering-eng-vpc.accept_status}"
}

output "peering_eng_vpc_id" {
  value = "${aws_vpc_peering_connection.peering-eng-vpc.id}"
}

output "peering_eng_vpc_id_string" {
  value = "${aws_vpc_peering_connection.peering-eng-vpc.id},${data.terraform_remote_state.vpc.vpc_cidr_block},${var.environment_name}"
}
