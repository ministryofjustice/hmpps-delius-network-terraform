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
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface LB decoupled"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-interface-lb-decoupled", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_lb_decoupled" {
  value = "${aws_security_group.weblogic_interface_lb_decoupled.id}"
}

resource "aws_security_group_rule" "interface_lb_iaps_ingress_tls" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb_decoupled.id}"
  source_security_group_id = "${aws_security_group.iaps_api_out.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "IAPS Ingress (TLS)"
}
