# define security groups only for delius-core to from mis

## Apply this SG to Delius DB to enable connection from MIS
resource "aws_security_group" "delius_core_db_in_from_mis" {
  name        = "${var.environment_name}-delius-core-db-in-from-mis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Delius Database in from MIS"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-delius-core-db-in-from-mis"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_core_db_in_from_mis_id" {
  value = aws_security_group.delius_core_db_in_from_mis.id
}

resource "aws_security_group_rule" "delius_core_db_in_from_mis" {
  security_group_id        = aws_security_group.delius_core_db_in_from_mis.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = aws_security_group.mis_out_to_delius_db.id
  description              = "TF - Delius DB in from MIS"
}

### NOTE:
## This security group is now mis named because it enable ingress & egress of MIS* DBs
## with the RMAN Catalogue in the engineering platform.
## Prefer this to raising the Security group limit of 5 on each netowrk interface in each AWS account.

## Apply this SG to MIS to enable connection to Delius DB
resource "aws_security_group" "mis_out_to_delius_db" {
  name        = "${var.environment_name}-mis-out-to-delius-db"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "MIS out to Delius Database"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-mis-out-to-delius-db"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_mis_out_to_delius_db_id" {
  value = aws_security_group.mis_out_to_delius_db.id
}

resource "aws_security_group_rule" "mis_out_to_delius_db" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = aws_security_group.delius_core_db_in_from_mis.id
  description              = "TF - MIS out to Delius Database"
}

resource "aws_security_group_rule" "db_to_eng_rman_catalog_out" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.rman_catalog
  description              = "RMAN Catalog out"
}

resource "aws_security_group_rule" "eng_rman_catalog_db_in" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.rman_catalog
  description              = "RMAN Catalog in"
}

resource "aws_security_group_rule" "eng_oem_db_in_22" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "22"
  to_port                  = "22"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 22"
}

resource "aws_security_group_rule" "eng_oem_db_in_1521" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 1521"
}

resource "aws_security_group_rule" "eng_oem_db_in_3872" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "3872"
  to_port                  = "3872"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 3872"
}

resource "aws_security_group_rule" "db_to_eng_oem_out_4903" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "4903"
  to_port                  = "4903"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM out 4903"
}

resource "aws_security_group_rule" "management_db_in" {
  security_group_id        = aws_security_group.mis_out_to_delius_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = aws_security_group.management_server.id
  description              = "Management server in"
}

#########################################################################
## Apply this SG to MIS to enable connection to RMAN Catalogue and OEM ##
#########################################################################
resource "aws_security_group" "mis_db_in_out_rman_cat" {
  name        = "${var.environment_name}-mis-db-in-out-to-rman-cat"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "MIS in and out to RMAN Catalogue"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-mis-db-in-out-to-rman-cat"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_mis_db_in_out_rman_cat_id" {
  value = aws_security_group.mis_db_in_out_rman_cat.id
}

resource "aws_security_group_rule" "mis_db_to_eng_rman_catalog_out" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.rman_catalog
  description              = "RMAN Catalog out"
}

resource "aws_security_group_rule" "eng_rman_catalog_mis_db_in" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.rman_catalog
  description              = "RMAN Catalog in"
}

resource "aws_security_group_rule" "eng_oem_mis_db_in_22" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "22"
  to_port                  = "22"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 22"
}

resource "aws_security_group_rule" "eng_oem_mis_db_in_1521" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 1521"
}

resource "aws_security_group_rule" "eng_oem_mis_db_in_3872" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "3872"
  to_port                  = "3872"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM in 3872"
}

resource "aws_security_group_rule" "eng_oem_mis_db_out_4903" {
  security_group_id        = aws_security_group.mis_db_in_out_rman_cat.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "4903"
  to_port                  = "4903"
  source_security_group_id = data.terraform_remote_state.ora_db_op_security_groups.outputs.sg_map_ids.oem
  description              = "OEM out 4903"
}

