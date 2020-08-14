# define security groups only for iaps
# External
resource "aws_security_group" "iaps_external_lb_in" {
  name        = "${var.environment_name}-delius-core-${var.iaps_app_name}-external-lb-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "External LB incoming"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}_${var.iaps_app_name}_external-lb_in_in"
      "Type" = "WEB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS
resource "aws_security_group" "iaps_db_in" {
  name        = "${var.environment_name}-delius-core-${var.iaps_app_name}-db-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "db incoming"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}_${var.iaps_app_name}_db_in"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#API
resource "aws_security_group" "iaps_api_in" {
  name        = "${var.environment_name}-delius-core-${var.iaps_app_name}-api-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api incoming"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}_${var.iaps_app_name}_api_in"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "iaps_api_out" {
  name        = "${var.environment_name}-delius-core-${var.iaps_app_name}-api-out"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api outgoing"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}_${var.iaps_app_name}_api_out"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "iaps_egress_interface_lb_tls" {
  security_group_id        = aws_security_group.iaps_api_out.id
  source_security_group_id = aws_security_group.weblogic_interface_lb_decoupled.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "IAPS Egress (TLS)"
}

