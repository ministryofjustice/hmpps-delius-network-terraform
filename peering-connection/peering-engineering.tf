# Engineering VPC PEER CONNECTION

resource "aws_vpc_peering_connection" "peering-eng-vpc" {
  peer_owner_id = data.terraform_remote_state.vpc.outputs.eng_vpc_account_id
  peer_vpc_id   = data.terraform_remote_state.vpc.outputs.eng_vpc_id
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-to-eng-vpc"
    },
  )
}

module "route-to-eng" {
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

  destination_cidr_block = data.terraform_remote_state.vpc.outputs.eng_vpc_cidr
  vpc_peer_id            = aws_vpc_peering_connection.peering-eng-vpc.id
  create                 = 1
}

