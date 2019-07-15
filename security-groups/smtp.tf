###SG group for SMTP and SES

#-------------------------------------------------------------
### Create SG Group
#-------------------------------------------------------------
resource "aws_security_group" "smtp_ses" {
  name        = "${var.environment_name}-smtp-ses"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Smtp"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-smtp-ses", "Type", "SMTP-SES"))}"
}

###SG required for yum outbound
resource "aws_security_group" "https_out" {
  name        = "${var.environment_name}-https-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Smtp"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-https-out", "Type", "HTTPS"))}"
}
