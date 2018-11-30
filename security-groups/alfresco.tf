# define security groups only for alfresco
# External
resource "aws_security_group" "alfresco_external_lb_in" {
  name        = "${var.environment_name}-delius-core-${var.alfresco_app_name}-external-lb-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "External LB incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_external-lb_in_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# NGINX
resource "aws_security_group" "alfresco_nginx_in" {
  name        = "${var.environment_name}-delius-core-${var.alfresco_app_name}-nginx-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Nginx incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_nginx_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# RDS
resource "aws_security_group" "alfresco_db_in" {
  name        = "${var.environment_name}-delius-core-${var.alfresco_app_name}-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "db incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#API
# Internal
resource "aws_security_group" "alfresco_internal_lb_in" {
  name        = "${var.environment_name}-delius-core-${var.alfresco_app_name}-internal-lb-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "internal LB incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_internal-lb_in_in", "Type", "WEB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alfresco_api_in" {
  name        = "${var.environment_name}-delius-core-${var.alfresco_app_name}-api-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "api incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_api_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}
