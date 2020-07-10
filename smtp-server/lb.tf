#smtp lb
resource "aws_elb" "smtp_lb" {
 name                  = "${var.environment_name}-${local.app_name}-elb"
 internal              = true
 subnets               = ["${local.private_subnet_ids}"]
 tags                  = "${var.tags}"
 security_groups       = ["${local.sg_smtp_ses}"]
 listener {
   instance_port       = "25"
   instance_protocol   = "tcp"
   lb_port             = "25"
   lb_protocol         = "tcp"
 }
 health_check {
   healthy_threshold   = 2
   unhealthy_threshold = 2
   timeout             = 3
   target              = "TCP:25"
   interval            = 30
 }
}



resource "aws_route53_record" "smtp_lb_private" {
 zone_id = "${local.private_zone_id}"
 name    = "${local.app_name}.${local.internal_domain}"
 type    = "CNAME"
 ttl     = "300"
 records = ["${aws_elb.smtp_lb.dns_name}"]
}
