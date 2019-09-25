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

#################
# DNS migration to gov domain

# strategic public zone - will only create whilst the main domain is in the old format
# once the main one is updated, all records in this zone will need to be manually deleted
# and then run terraform to remove this dns
# any projects (ie spg) depending on this 2nd domain name must do a check before creating records that a split is required

# see hmpps-delius-spg-shared-terraform/ecs-iso/ecs--network-public-nlb.tf : resource "aws_route53_record" "strategic_dns_ext_entry"
resource "aws_route53_zone" "strategic_public_zone" {
  count = "${(local.public_domain == local.strategic_public_domain) ? 0 : 1}"
  name = "${local.strategic_public_domain}"
  vpc {
    vpc_id = "${module.vpc.vpc_id}"
  }
}




data "aws_acm_certificate" "ssl_certificate_details" {
  domain      = "*.${local.public_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
