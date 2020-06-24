###SG groups for SMTP and SES

output "sg_smtp_ses" {
  value = aws_security_group.smtp_ses.id
}

output "sg_https_out" {
  value = aws_security_group.https_out.id
}

