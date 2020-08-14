# Bastion VPC PEER CONNECTION

resource "aws_vpc_peering_connection" "peering-bastion-vpc" {
  peer_owner_id = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.account_id
  peer_vpc_id   = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.id
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-to-bastion-vpc"
    },
  )
}

## Another way do it
# module "route-to-bastion-vpc-cidr" {
#   source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//routes//vpc_peer"
#
#   route_table_id = [
#     "${data.terraform_remote_state.vpc.vpc_public-routetable-az1}",
#     "${data.terraform_remote_state.vpc.vpc_public-routetable-az2}",
#     "${data.terraform_remote_state.vpc.vpc_public-routetable-az3}",
#     "${data.terraform_remote_state.vpc.vpc_private-routetable-az1}",
#     "${data.terraform_remote_state.vpc.vpc_private-routetable-az2}",
#     "${data.terraform_remote_state.vpc.vpc_private-routetable-az3}",
#     "${data.terraform_remote_state.vpc.vpc_db-routetable-az1}",
#     "${data.terraform_remote_state.vpc.vpc_db-routetable-az2}",
#     "${data.terraform_remote_state.vpc.vpc_db-routetable-az3}",
#   ]
#
#   destination_cidr_block = "${data.terraform_remote_state.bastion_remote_vpc.vpc.cidr}"
#   vpc_peer_id            = "${aws_vpc_peering_connection.peering-bastion-vpc.id}"
#   create                 = 1
# }

module "route-to-bastion-vpc-public-cidr-az1" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.public_cidr.az1
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

module "route-to-bastion-vpc-public-cidr-az2" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.public_cidr.az2
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

module "route-to-bastion-vpc-public-cidr-az3" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.public_cidr.az3
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

# ## Route to bastion private

module "route-to-bastion-vpc-private-cidr-az1" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.private_cidr.az1
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

module "route-to-bastion-vpc-private-cidr-az2" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.private_cidr.az2
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

module "route-to-bastion-vpc-private-cidr-az3" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/vpc_peer?ref=terraform-0.12"

  route_table_id = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  destination_cidr_block = data.terraform_remote_state.bastion_remote_vpc.outputs.vpc.private_cidr.az3
  vpc_peer_id            = aws_vpc_peering_connection.peering-bastion-vpc.id
  create                 = 1
}

