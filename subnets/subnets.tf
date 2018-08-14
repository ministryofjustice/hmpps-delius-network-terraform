resource "aws_subnet" "public_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.public_subnet,3 ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}_public", "Type", "public"))}"
}

resource "aws_subnet" "private_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.private_subnet,3 ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}_private", "Type", "private"))}"
}

resource "aws_subnet" "db_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.db_subnet,3 ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}_db", "Type", "db"))}"
}
