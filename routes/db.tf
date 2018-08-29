resource "aws_route_table" "db" {
  count  = "${length(var.az_list)}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}_db_${element(var.az_list, count.index)}"))}"
}
