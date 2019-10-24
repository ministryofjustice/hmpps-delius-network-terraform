locals {
  route53_internal_domain = "${var.project_name}-${var.environment_type}.internal"
  public_domain           = "${var.subdomain}.${var.route53_domain_private}"
  strategic_public_domain = "${var.public_dns_child_zone}.${var.public_dns_parent_zone}"
}

# Private internal zone for easier lookups
resource "aws_route53_zone" "internal_zone" {
  name = "${local.route53_internal_domain}"

  vpc {
    vpc_id = "${module.vpc.vpc_id}"
  }
}

#existing preprod.delius.probation.hmpps.dsd.ioy
data "aws_route53_zone" "public_hosted_zone" {
  name = "${local.public_domain}"
}


data "aws_acm_certificate" "ssl_certificate_details" {
  domain      = "*.${local.public_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}


# Strategic gov.uk public domain
resource "aws_route53_zone" "strategic_zone" {
  # Prod strategic zone is handled by Ansible
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  name = "${local.strategic_public_domain}"

}

resource "aws_route53_record" "delegation_record" {
  # The zone id of the prod R53 zone
  zone_id = "${var.strategic_parent_zone_id}"
  name    = "${local.strategic_public_domain}"
  type    = "NS"
  ttl     = "300"
  records = ["${aws_route53_zone.strategic_zone.name_servers}"]
  # Use alternative provider which assumes cross account role in prod for managing R53 records
  provider = "aws.delius_prod_acct_r53_delegation"
}