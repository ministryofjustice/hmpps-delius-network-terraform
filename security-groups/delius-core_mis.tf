# define security groups only for delius-core to from mis

resource "aws_security_group" "delius_core_mis_db_in_out" {
  name        = "${var.environment_name}-delius-core-mis-db-in-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Database in from MIS"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-core-mis-db-in-out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_core_mis_db_in_out_id" {
  value = "${aws_security_group.delius_core_mis_db_in_out.id}"
}

resource "aws_security_group_rule" "delius_core_mis_db_in" {
  security_group_id = "${aws_security_group.delius_core_mis_db_in_out.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "TF - MIS DB in"
}

resource "aws_security_group_rule" "delius_core_mis_db_out" {
  security_group_id = "${aws_security_group.delius_core_mis_db_in_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "TF - MIS DB out"
}
