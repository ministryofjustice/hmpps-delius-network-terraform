###SG groups for SMTP and SES

output "sg_smtp_ses" {
  value = "${aws_security_group.smtp_ses.id}"
}
