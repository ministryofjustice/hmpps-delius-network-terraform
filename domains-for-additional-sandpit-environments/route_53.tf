locals {
  route53_internal_domain = "${var.project_name}-${var.environment_type}.internal"
  public_domain           = "${var.subdomain}.${var.route53_domain_private}"
  strategic_public_domain = "${var.public_dns_child_zone}.${var.public_dns_parent_zone}"
}


# Private internal zone for easier lookups
resource "aws_route53_zone" "internal_zone" {
  name = "${local.route53_internal_domain}"

  vpc {
    vpc_id = "${data.terraform_remote_state.vpc_main_sandpit.vpc_id}"
  }
}


# Strategic *.probation.service.justice.gov.uk public domain
resource "aws_route53_zone" "strategic_zone" {
  # Prod strategic zone is handled by Ansible
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  name  = "${local.strategic_public_domain}"
}
