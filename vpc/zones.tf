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
