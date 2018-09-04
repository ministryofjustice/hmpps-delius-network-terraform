output "environment_name" {
  value = "${local.environment_name}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "bastion_peering_id" {
  value = "${aws_vpc_peering_connection.bastion_peering.id}"
}

output "bastion_peering_id_string" {
  value = "${aws_vpc_peering_connection.bastion_peering.id},${aws_vpc.vpc.cidr_block},${local.environment_name}"
}

output "vpc_account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "vpc_role_arn" {
  value = "${var.role_arn}"
}
