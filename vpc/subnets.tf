# public
resource "aws_subnet" "public_subnet_az1" {
  cidr_block        = "${cidrsubnet(var.public_subnet, 3, 1 )}"
  availability_zone = "${var.availability_zone["az1"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-public-${var.availability_zone["az1"]}", "Type", "public"))}"
}

resource "aws_subnet" "public_subnet_az2" {
  cidr_block        = "${cidrsubnet(var.public_subnet, 3 ,2 )}"
  availability_zone = "${var.availability_zone["az2"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-public-${var.availability_zone["az2"]}", "Type", "public"))}"
}

resource "aws_subnet" "public_subnet_az3" {
  cidr_block        = "${cidrsubnet(var.public_subnet, 3 ,3 )}"
  availability_zone = "${var.availability_zone["az3"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-public-${var.availability_zone["az3"]}", "Type", "public"))}"
}

# private
resource "aws_subnet" "private_subnet_az1" {
  cidr_block        = "${cidrsubnet(var.private_subnet, 3, 1 )}"
  availability_zone = "${var.availability_zone["az1"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-private-${var.availability_zone["az1"]}", "Type", "private"))}"
}

resource "aws_subnet" "private_subnet_az2" {
  cidr_block        = "${cidrsubnet(var.private_subnet, 3 ,2 )}"
  availability_zone = "${var.availability_zone["az2"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-private-${var.availability_zone["az2"]}", "Type", "private"))}"
}

resource "aws_subnet" "private_subnet_az3" {
  cidr_block        = "${cidrsubnet(var.private_subnet, 3 ,3 )}"
  availability_zone = "${var.availability_zone["az3"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-private-${var.availability_zone["az3"]}", "Type", "private"))}"
}

# db
resource "aws_subnet" "db_subnet_az1" {
  cidr_block        = "${cidrsubnet(var.db_subnet, 3, 1 )}"
  availability_zone = "${var.availability_zone["az1"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-${var.availability_zone["az1"]}", "Type", "db"))}"
}

resource "aws_subnet" "db_subnet_az2" {
  cidr_block        = "${cidrsubnet(var.db_subnet, 3 ,2 )}"
  availability_zone = "${var.availability_zone["az2"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-${var.availability_zone["az2"]}", "Type", "db"))}"
}

resource "aws_subnet" "db_subnet_az3" {
  cidr_block        = "${cidrsubnet(var.db_subnet, 3 ,3 )}"
  availability_zone = "${var.availability_zone["az3"]}"
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-${var.availability_zone["az3"]}", "Type", "db"))}"
}
