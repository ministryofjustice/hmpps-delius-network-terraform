# ############################################
# ROUTE53
# ############################################
resource "aws_route53_record" "internal_monitoring_dns" {
  name    = "${local.server_dns}.${local.internal_domain}"
  type    = "A"
  zone_id = "${local.private_zone_id}"

  alias {
    name                   = "${module.create_app_alb.lb_dns_name}"
    zone_id                = "${module.create_app_alb.lb_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "external_monitoring_dns" {
  zone_id = "${local.public_zone_id}"
  name    = "${local.server_dns}.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${module.create_app_alb.lb_dns_name}"
    zone_id                = "${module.create_app_alb.lb_zone_id}"
    evaluate_target_health = false
  }
}

# logstash
resource "aws_route53_record" "internal_logstash_dns" {
  zone_id = "${local.private_zone_id}"
  name    = "logstash.${local.internal_domain}"
  type    = "A"

  alias {
    name                   = "${aws_elb.mon_lb.dns_name}"
    zone_id                = "${aws_elb.mon_lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "external_logstash_dns" {
  zone_id = "${local.public_zone_id}"
  name    = "logstash.${local.external_domain}"
  type    = "A"

  alias {
    name                   = "${aws_elb.mon_lb.dns_name}"
    zone_id                = "${aws_elb.mon_lb.zone_id}"
    evaluate_target_health = false
  }
}
