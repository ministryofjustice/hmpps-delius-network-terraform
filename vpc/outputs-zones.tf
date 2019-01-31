output "private_zone_name" {
  value = "${local.route53_internal_domain}"
}

output "private_zone_id" {
  value = "${aws_route53_zone.internal_zone.zone_id}"
}

output "public_zone_id" {
  value = "${data.aws_route53_zone.public_hosted_zone.zone_id}"
}

output "public_zone_name" {
  value = "${local.public_domain}"
}

output "public_ssl_arn" {
  value = "${data.aws_acm_certificate.ssl_certificate_details.arn}"
}

output "public_ssl_domain" {
  value = "${data.aws_acm_certificate.ssl_certificate_details.domain}"
}
