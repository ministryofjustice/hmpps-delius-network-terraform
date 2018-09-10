output "private_zone_name" {
  value = "${aws_route53_zone.internal_zone.name}"
}

output "private_zone_id" {
  value = "${aws_route53_zone.internal_zone.zone_id}"
}
