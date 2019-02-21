# define security groups only for iaps outputs
# External
output "sg_iaps_external_lb_in" {
  value = "${aws_security_group.iaps_external_lb_in.id}"
}

# iaps_db_in
output "sg_iaps_db_in" {
  value = "${aws_security_group.iaps_db_in.id}"
}

# iaps_api_in
output "sg_iaps_api_in" {
  value = "${aws_security_group.iaps_api_in.id}"
}
