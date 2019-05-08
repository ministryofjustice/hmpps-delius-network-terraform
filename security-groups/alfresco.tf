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


resource "aws_security_group_rule" "alfresco_db_in" {
  security_group_id = "${aws_security_group.alfresco_db_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "5432"
  to_port           = "5432"
  cidr_blocks       = "${data.terraform_remote_state.vpc.eng_vpc_cidr}"
  description       = "TF - alfresco_db_in"
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

# Elasticache
resource "aws_security_group" "alfresco_elasticache_in" {
  name        = "${var.environment_name}-${var.alfresco_app_name}-elasticache-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "elasticache incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_elasticache_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# EFS
resource "aws_security_group" "alfresco_efs_in" {
  name        = "${var.environment_name}-${var.alfresco_app_name}-efs-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "efs incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_efs_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# Elasticsearch
resource "aws_security_group" "alfresco_es_in" {
  name        = "${var.environment_name}-${var.alfresco_app_name}-elasticsearch-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "elasticsearch"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}_${var.alfresco_app_name}_elasticsearch_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}
