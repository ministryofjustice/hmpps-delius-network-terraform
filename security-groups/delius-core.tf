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

# Application/interface
resource "aws_security_group" "weblogic_interface_lb_decoupled" {
  name        = "${var.environment_name}-weblogic-interface-lb-decoupled"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic interface LB decoupled"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-weblogic-interface-lb-decoupled"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_lb_decoupled" {
  value = aws_security_group.weblogic_interface_lb_decoupled.id
}

# Delius management server
resource "aws_security_group" "management_server" {
  name        = "${var.environment_name}-management-server-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Management instance SG"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-management-server-sg"
      "Type" = "Private"
    },
  )
}

output "sg_management_server_id" {
  value = aws_security_group.management_server.id
}

resource "aws_security_group_rule" "management_db_out" {
  security_group_id        = aws_security_group.management_server.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = aws_security_group.mis_out_to_delius_db.id
  description              = "MIS DB out"
}

