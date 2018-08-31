resource "aws_route_table" "private" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}-private"))}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.az_list)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index )}"
  subnet_id      = "${data.aws_subnet_ids.private_subnets.ids[count.index]}"
}

resource "aws_route" "private_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.private.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${data.aws_vpc_peering_connection.bastion_peering.id}"
}
