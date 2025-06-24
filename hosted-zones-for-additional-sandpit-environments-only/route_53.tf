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
  # COUNT ENSURES IS NOT CREATED IN PROD as per normal VPC rules (actually we only want in sandpit)
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"

  name  = "${local.strategic_public_domain}"
}



# Delegation record so we can access the strategic route53 zone from prod
resource "aws_route53_record" "delegation_record" {
  # COUNT ENSURES IS NOT CREATED IN PROD as per normal VPC rules (actually we only want in sandpit)
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"

  # The zone id of the prod R53 zone
  zone_id = "${var.strategic_parent_zone_id}"
  name    = "${local.strategic_public_domain}"
  type    = "NS"
  ttl     = "300"
  records = ["${aws_route53_zone.strategic_zone.name_servers}"]
  # Use alternative provider which assumes cross account role in prod for managing R53 records
  provider = "aws.delius_prod_acct_r53_delegation"
}
