resource "aws_eip" "nat" {
  count = "${length(var.az_list)}"
  vpc   = true
  tags  = "${merge(var.tags, map("Name", "${local.environment_name}-nat-eip-${count.index}"))}"
}

resource "aws_nat_gateway" "gw" {
  depends_on    = ["aws_internet_gateway.main"]
  count         = "${length(var.az_list)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${data.aws_subnet_ids.public_subnets.ids[count.index]}"
  tags          = "${merge(var.tags, map("Name", "${local.environment_name}-nat-gw-${count.index}"))}"
}
