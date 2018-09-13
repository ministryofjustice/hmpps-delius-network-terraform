output "private_zone_name" {
  value = "${aws_route53_zone.internal_zone.name}"
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
