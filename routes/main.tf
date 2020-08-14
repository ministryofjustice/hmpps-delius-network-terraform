data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "natgateway/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "internetgateway" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "internetgateway/terraform.tfstate"
    region = var.region
  }
}

#
locals {
  route_table_public_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-routetable-az3,
  ]

  route_table_private_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-routetable-az3,
  ]

  route_table_db_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-routetable-az3,
  ]

  nat_gateway_ids = [
    data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-id-az1,
    data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-id-az2,
    data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-id-az3,
  ]

  destination_cidr_blocks = [
    "0.0.0.0/0",
    "0.0.0.0/0",
    "0.0.0.0/0",
  ]
}

############################
# MODULES
############################
module "route-to-internet" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/internetgateway?ref=terraform-0.12"
  route_table_id         = local.route_table_public_ids
  destination_cidr_block = local.destination_cidr_blocks
  gateway_id             = data.terraform_remote_state.internetgateway.outputs.internetgateway_env_igw_id
}

# ## TODO The following exists to assist with debug or development
# ## it is not to be applied to production and this block should
# ## be deleted.
# # PRIVATE NETWORK
module "route-private-to-nat" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/natgateway?ref=terraform-0.12"
  route_table_id         = local.route_table_private_ids
  destination_cidr_block = local.destination_cidr_blocks
  nat_gateway_id         = local.nat_gateway_ids
}

# ## TODO The following exists to assist with debug or development
# ## it is not to be applied to production and this block should
# ## be deleted.
# # DB NETWORK
module "route-db-to-nat" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/routes/natgateway?ref=terraform-0.12"
  route_table_id         = local.route_table_db_ids
  destination_cidr_block = local.destination_cidr_blocks
  nat_gateway_id         = local.nat_gateway_ids
}

