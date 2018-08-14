resource "aws_route_table" "public" {
  count  = "3"
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}_public"))}"
}

resource "aws_route" "public_internet" {
  count                  = "${length(var.az_list)}"
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${data.aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.az_list)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index )}"
  subnet_id      = "${data.aws_subnet_ids.public_subnets.ids[count.index]}"
}
