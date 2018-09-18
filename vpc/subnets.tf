# public
module "public_subnet_az1" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 5, 29 )}"
  availability_zone       = "${var.availability_zone["az1"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-public-${var.availability_zone["az1"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "public"))}"
}

module "public_subnet_az2" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 5, 30 )}"
  availability_zone       = "${var.availability_zone["az2"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-public-${var.availability_zone["az2"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "public"))}"
}

module "public_subnet_az3" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 5, 31 )}"
  availability_zone       = "${var.availability_zone["az3"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-public-${var.availability_zone["az3"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "public"))}"
}

# private
module "private_subnet_az1" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 2, 0 )}"
  availability_zone       = "${var.availability_zone["az1"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-private-${var.availability_zone["az1"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "private"))}"
}

module "private_subnet_az2" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 2, 1 )}"
  availability_zone       = "${var.availability_zone["az2"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-private-${var.availability_zone["az2"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "private"))}"
}

module "private_subnet_az3" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 2, 2 )}"
  availability_zone       = "${var.availability_zone["az3"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-private-${var.availability_zone["az3"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "private"))}"
}

# db
module "db_subnet_az1" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 4, 12 )}"
  availability_zone       = "${var.availability_zone["az1"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-db-${var.availability_zone["az1"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "db"))}"
}

module "db_subnet_az2" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 4, 13 )}"
  availability_zone       = "${var.availability_zone["az2"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-db-${var.availability_zone["az2"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "db"))}"
}

module "db_subnet_az3" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//subnets"
  subnet_cidr_block       = "${cidrsubnet(var.vpc_supernet, 5, 28 )}"
  availability_zone       = "${var.availability_zone["az3"]}"
  map_public_ip_on_launch = "false"
  subnet_name             = "${var.environment_name}-db-${var.availability_zone["az3"]}"
  vpc_id                  = "${module.vpc.vpc_id}"
  tags                    = "${merge(var.tags, map("Type", "db"))}"
}
