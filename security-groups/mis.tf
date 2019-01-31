# define security groups only for mis

# db
resource "aws_security_group" "mis_db_in" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "db incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Common
resource "aws_security_group" "mis_common" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-common-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "common sg"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_common_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#App
resource "aws_security_group" "mis_app_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-api-lb-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_api_lb_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mis_app_in" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-api-instance-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_api_instance_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#LDAP
resource "aws_security_group" "ldap_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api lb incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_ldap_lb", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# LDAP Proxy
resource "aws_security_group" "ldap_proxy" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-proxy"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api proxy incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_ldap_proxy", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ldap_inst" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-inst"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api instance"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.mis_app_name}_ldap_inst", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}
