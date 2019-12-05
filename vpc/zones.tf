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

# Existing *.delius.probation.hmpps.dsd.io public domain
data "aws_route53_zone" "public_hosted_zone" {
  name = "${local.public_domain}"
}

data "aws_acm_certificate" "ssl_certificate_details" {
  domain      = "*.${local.public_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# Strategic *.probation.service.justice.gov.uk public domain
resource "aws_route53_zone" "strategic_zone" {
  # Prod strategic zone is handled by Ansible
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  name  = "${local.strategic_public_domain}"
}

# Delegation record so we can access the strategic route53 zone from prod
resource "aws_route53_record" "delegation_record" {
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
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

resource "aws_acm_certificate" "cert" {
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  domain_name       = "*.${local.strategic_public_domain}"
  validation_method = "DNS"
  tags              = "${merge(var.tags, map("Name", "${local.strategic_public_domain}"))}"
  lifecycle {
    create_before_destroy = true
  }
}

# Validation record for the strategic ssl cert
resource "aws_route53_record" "cert_validation" {
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  zone_id    = "${aws_route53_zone.strategic_zone.zone_id}"
  name       = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type       = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  records    = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl        = 60
  depends_on = ["aws_acm_certificate.cert"]
}
# This resource allows terraform to wait till the certificate has been validated using the above r53 record
resource "aws_acm_certificate_validation" "cert_validation" {
  # TODO once/if public zones are migrated to this strategic zone, prod zone should be managed by TF - this will require an import
  count = "${var.environment_name != "delius-prod" ? 1 : 0}"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
