# define security groups only for delius-core to from mis

## Apply this SG to Delius DB to enable connection from MIS
resource "aws_security_group" "delius_core_db_in_from_mis" {
  name        = "${var.environment_name}-delius-core-db-in-from-mis"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius Database in from MIS"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-core-db-in-from-mis", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_core_db_in_from_mis_id" {
  value = "${aws_security_group.delius_core_db_in_from_mis.id}"
}

resource "aws_security_group_rule" "delius_core_db_in_from_mis" {
  security_group_id        = "${aws_security_group.delius_core_db_in_from_mis.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.mis_out_to_delius_db.id}"
  description              = "TF - Delius DB in from MIS"
}


## Apply this SG to MIS to enable connection to Delius DB
resource "aws_security_group" "mis_out_to_delius_db" {
  name        = "${var.environment_name}-mis-out-to-delius-db"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "MIS out to Delius Database"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-mis-out-to-delius-db", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_mis_out_to_delius_db_id" {
  value = "${aws_security_group.mis_out_to_delius_db.id}"
}

resource "aws_security_group_rule" "mis_out_to_delius_db" {
  security_group_id        = "${aws_security_group.mis_out_to_delius_db.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.delius_core_db_in_from_mis.id}"
  description              = "TF - MIS out to Delius Database"
}
