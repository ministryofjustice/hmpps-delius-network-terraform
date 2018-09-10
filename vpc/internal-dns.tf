locals {
  route53_internal_domain = "${var.project_name}-${var.environment_type}.internal"
}

# Private internal zone for easier lookups
resource "aws_route53_zone" "internal_zone" {
  name   = "${local.route53_internal_domain}"
  vpc_id = "${module.vpc.vpc_id}"
}
