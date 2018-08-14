resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_supernet}"
  tags       = "${merge(var.tags, map("Name", "${local.environment_name}"))}"
}
