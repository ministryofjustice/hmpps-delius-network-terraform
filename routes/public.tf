resource "aws_route_table" "public" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}-public"))}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.az_list)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${data.aws_subnet_ids.public_subnets.ids[count.index]}"
}

resource "aws_route" "public_internet" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${data.aws_internet_gateway.igw.id}"
}

resource "aws_route" "public_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.public.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${data.aws_vpc_peering_connection.bastion_peering.id}"
}
