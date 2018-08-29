resource "aws_subnet" "public_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.public_subnet,length(var.az_list) ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-public-${element(var.az_list, count.index)}", "Type", "public"))}"
}

resource "aws_subnet" "private_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.private_subnet,length(var.az_list) ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-private-${element(var.az_list, count.index)}", "Type", "private"))}"
}

resource "aws_subnet" "db_subnet" {
  count             = "${length(var.az_list)}"
  cidr_block        = "${cidrsubnet(var.db_subnet,length(var.az_list) ,count.index )}"
  availability_zone = "${var.az_list[count.index]}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-${element(var.az_list, count.index)}", "Type", "db"))}"
}
