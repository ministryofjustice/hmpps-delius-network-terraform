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

### subnets
# public

output "vpc_public-subnet-az1" {
  value = "${aws_subnet.public_subnet_az1.id}"
}

output "vpc_public-subnet-az1-cidr_block" {
  value = "${aws_subnet.public_subnet_az1.cidr_block}"
}

output "vpc_public-subnet-az1-availability_zone" {
  value = "${aws_subnet.public_subnet_az1.availability_zone}"
}

output "vpc_public-subnet-az2" {
  value = "${aws_subnet.public_subnet_az2.id}"
}

output "vpc_public-subnet-az2-cidr_block" {
  value = "${aws_subnet.public_subnet_az2.cidr_block}"
}

output "vpc_public-subnet-az2-availability_zone" {
  value = "${aws_subnet.public_subnet_az2.availability_zone}"
}

output "vpc_public-subnet-az3" {
  value = "${aws_subnet.public_subnet_az3.id}"
}

output "vpc_public-subnet-az3-cidr_block" {
  value = "${aws_subnet.public_subnet_az3.cidr_block}"
}

output "vpc_public-subnet-az3-availability_zone" {
  value = "${aws_subnet.public_subnet_az3.availability_zone}"
}

# private

output "vpc_private-subnet-az1" {
  value = "${aws_subnet.private_subnet_az1.id}"
}

output "vpc_private-subnet-az1-cidr_block" {
  value = "${aws_subnet.private_subnet_az1.cidr_block}"
}

output "vpc_private-subnet-az1-availability_zone" {
  value = "${aws_subnet.private_subnet_az1.availability_zone}"
}

output "vpc_private-subnet-az2" {
  value = "${aws_subnet.private_subnet_az2.id}"
}

output "vpc_private-subnet-az2-cidr_block" {
  value = "${aws_subnet.private_subnet_az2.cidr_block}"
}

output "vpc_private-subnet-az2-availability_zone" {
  value = "${aws_subnet.private_subnet_az2.availability_zone}"
}

output "vpc_private-subnet-az3" {
  value = "${aws_subnet.private_subnet_az3.id}"
}

output "vpc_private-subnet-az3-cidr_block" {
  value = "${aws_subnet.private_subnet_az3.cidr_block}"
}

output "vpc_private-subnet-az3-availability_zone" {
  value = "${aws_subnet.private_subnet_az3.availability_zone}"
}

# db

output "vpc_db-subnet-az1" {
  value = "${aws_subnet.db_subnet_az1.id}"
}

output "vpc_db-subnet-az1-cidr_block" {
  value = "${aws_subnet.db_subnet_az1.cidr_block}"
}

output "vpc_db-subnet-az1-availability_zone" {
  value = "${aws_subnet.db_subnet_az1.availability_zone}"
}

output "vpc_db-subnet-az2" {
  value = "${aws_subnet.db_subnet_az2.id}"
}

output "vpc_db-subnet-az2-cidr_block" {
  value = "${aws_subnet.db_subnet_az2.cidr_block}"
}

output "vpc_db-subnet-az2-availability_zone" {
  value = "${aws_subnet.db_subnet_az2.availability_zone}"
}

output "vpc_db-subnet-az3" {
  value = "${aws_subnet.db_subnet_az3.id}"
}

output "vpc_db-subnet-az3-cidr_block" {
  value = "${aws_subnet.db_subnet_az3.cidr_block}"
}

output "vpc_db-subnet-az3-availability_zone" {
  value = "${aws_subnet.db_subnet_az3.availability_zone}"
}
