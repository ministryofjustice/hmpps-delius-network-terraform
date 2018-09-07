# define security groups only for delius-core

# resource "aws_security_group" "delius_core_delius_db_in" {
#   name        = "${local.environment_name}-delius-core-delius-db-in"
#   vpc_id      = "${data.aws_vpc.vpc.id}"
#   description = "Database in"
#   tags        = "${merge(var.tags, map("Name", "${local.environment_name}_delius_core_delius_db_in", "Type", "DB"))}"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
