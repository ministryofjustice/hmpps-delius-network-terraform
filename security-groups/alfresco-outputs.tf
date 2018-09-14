# define security groups only for alfresco outputs
# External
output "sg_alfresco_external_lb_in" {
  value = "${aws_security_group.alfresco_external_lb_in.id}"
}

# alfresco_nginx_in
output "sg_alfresco_nginx_in" {
  value = "${aws_security_group.alfresco_nginx_in.id}"
}

# alfresco_db_in
output "sg_alfresco_db_in" {
  value = "${aws_security_group.alfresco_db_in.id}"
}

# alfresco_internal_lb_in
output "sg_alfresco_internal_lb_in" {
  value = "${aws_security_group.alfresco_internal_lb_in.id}"
}

# alfresco_api_in
output "sg_alfresco_api_in" {
  value = "${aws_security_group.alfresco_api_in.id}"
}
