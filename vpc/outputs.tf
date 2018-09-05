output "tags" {
  value = "${var.tags}"
}

output "environment_name" {
  value = "${var.environment_name}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.vpc.vpc_cidr}"
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
  value = "${module.public_subnet_az1.subnetid}"
}

output "vpc_public-subnet-az1-cidr_block" {
  value = "${cidrsubnet(var.public_subnet, 3, 1 )}"
}

output "vpc_public-subnet-az1-availability_zone" {
  value = "${module.public_subnet_az1.availability_zone}"
}

output "vpc_public-subnet-az2" {
  value = "${module.public_subnet_az2.subnetid}"
}

output "vpc_public-subnet-az2-cidr_block" {
  value = "${cidrsubnet(var.public_subnet, 3, 2 )}"
}

output "vpc_public-subnet-az2-availability_zone" {
  value = "${module.public_subnet_az2.availability_zone}"
}

output "vpc_public-subnet-az3" {
  value = "${module.public_subnet_az3.subnetid}"
}

output "vpc_public-subnet-az3-cidr_block" {
  value = "${cidrsubnet(var.public_subnet, 3, 3 )}"
}

output "vpc_public-subnet-az3-availability_zone" {
  value = "${module.public_subnet_az3.availability_zone}"
}

#
# # private

output "vpc_private-subnet-az1" {
  value = "${module.private_subnet_az1.subnetid}"
}

output "vpc_private-subnet-az1-cidr_block" {
  value = "${cidrsubnet(var.private_subnet, 3, 1 )}"
}

output "vpc_private-subnet-az1-availability_zone" {
  value = "${module.private_subnet_az1.availability_zone}"
}

output "vpc_private-subnet-az2" {
  value = "${module.private_subnet_az2.subnetid}"
}

output "vpc_private-subnet-az2-cidr_block" {
  value = "${cidrsubnet(var.private_subnet, 3, 2 )}"
}

output "vpc_private-subnet-az2-availability_zone" {
  value = "${module.private_subnet_az2.availability_zone}"
}

output "vpc_private-subnet-az3" {
  value = "${module.private_subnet_az3.subnetid}"
}

output "vpc_private-subnet-az3-cidr_block" {
  value = "${cidrsubnet(var.private_subnet, 3, 3 )}"
}

output "vpc_private-subnet-az3-availability_zone" {
  value = "${module.private_subnet_az3.availability_zone}"
}

# db

output "vpc_db-subnet-az1" {
  value = "${module.db_subnet_az1.subnetid}"
}

output "vpc_db-subnet-az1-cidr_block" {
  value = "${cidrsubnet(var.db_subnet, 3, 1 )}"
}

output "vpc_db-subnet-az1-availability_zone" {
  value = "${module.db_subnet_az1.availability_zone}"
}

output "vpc_db-subnet-az2" {
  value = "${module.db_subnet_az2.subnetid}"
}

output "vpc_db-subnet-az2-cidr_block" {
  value = "${cidrsubnet(var.db_subnet, 3, 2 )}"
}

output "vpc_db-subnet-az2-availability_zone" {
  value = "${module.db_subnet_az2.availability_zone}"
}

output "vpc_db-subnet-az3" {
  value = "${module.db_subnet_az3.subnetid}"
}

output "vpc_db-subnet-az3-cidr_block" {
  value = "${cidrsubnet(var.db_subnet, 3, 3 )}"
}

output "vpc_db-subnet-az3-availability_zone" {
  value = "${module.db_subnet_az3.availability_zone}"
}

## routetables
# public
output "vpc_public-routetable-az1" {
  value = "${module.public_subnet_az1.routetableid}"
}

output "vpc_public-routetable-az2" {
  value = "${module.public_subnet_az2.routetableid}"
}

output "vpc_public-routetable-az3" {
  value = "${module.public_subnet_az3.routetableid}"
}

# private
output "vpc_private-routetable-az1" {
  value = "${module.private_subnet_az1.routetableid}"
}

output "vpc_private-routetable-az2" {
  value = "${module.private_subnet_az2.routetableid}"
}

output "vpc_private-routetable-az3" {
  value = "${module.private_subnet_az3.routetableid}"
}

# db
output "vpc_db-routetable-az1" {
  value = "${module.db_subnet_az1.routetableid}"
}

output "vpc_db-routetable-az2" {
  value = "${module.db_subnet_az2.routetableid}"
}

output "vpc_db-routetable-az3" {
  value = "${module.db_subnet_az3.routetableid}"
}
