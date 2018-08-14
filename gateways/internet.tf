resource "aws_internet_gateway" "main" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${local.environment_name}_igw"))}"
}
