#DEPRECATED - these SGs have been migrated to the spg-terraform project as they are not conusmed by other appliances
#
# Once all envs have had thier SGs replaced with the new ones - these SGs can be deleted
#
#
#

# spg_external_lb_in  = web to Front End LBs (techincally not used by NLB)
# spg_nginx_in = front end LB -> front end ISO server (either nginx, haproxy or spg-iso)
# port 9001 from POs and crcstubs only
# spg_internal_lb_in = internal classic LB infront of mpx
# spg_api_in = internal loadbalancer to mpx:
#   ports 61616-61617 (JMS from all)
#   ports 8989 (unsigned SOAP from spg-iso to spg-mpx)
#   ports 8181 (signed soap from haproxy to spg-iso)
# ssh_jenkins_in = port 2222 from any machine in engineering vpc (ie jenkins slave - for use by passwordless accounts like virtuoso)
#
# define security groups only for spg
# External
resource "aws_security_group" "spg_external_lb_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-external-lb-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "External LB incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_external-lb_in_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# NGINX
resource "aws_security_group" "spg_nginx_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-nginx-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Nginx incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_nginx_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# RDS
resource "aws_security_group" "spg_db_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "db incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#API
# Internal
resource "aws_security_group" "spg_internal_lb_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-internal-lb-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "internal LB incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_internal-lb_in_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "spg_api_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-api-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_api_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ssh_jenkins_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-ssh-jenkins-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "ssh access from jenkins"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_ssh_jenkins_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group_rule" "ssh_jenkins_in" {
  security_group_id = "${aws_security_group.ssh_jenkins_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "2222"
  to_port           = "2222"
  cidr_blocks       = [ "${data.terraform_remote_state.vpc.eng_vpc_cidr}" ]
  description       = "TF - ssh_jenkins_in"
}


# OUTPUTS
# define security groups only for spg outputs
# External
output "sg_spg_external_lb_in" {
  value = "${aws_security_group.spg_external_lb_in.id}"
}

# spg_nginx_in
output "sg_spg_nginx_in" {
  value = "${aws_security_group.spg_nginx_in.id}"
}

# spg_db_in
output "sg_spg_db_in" {
  value = "${aws_security_group.spg_db_in.id}"
}

# spg_internal_lb_in
output "sg_spg_internal_lb_in" {
  value = "${aws_security_group.spg_internal_lb_in.id}"
}

# spg_api_in
output "sg_spg_api_in" {
  value = "${aws_security_group.spg_api_in.id}"
}
