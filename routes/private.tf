resource "aws_route_table" "private" {
  count  = "${length(var.az_list)}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}_private_${element(var.az_list, count.index)}"))}"
}
