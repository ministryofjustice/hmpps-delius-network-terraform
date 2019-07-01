###SG group for SMTP and SES

#-------------------------------------------------------------
### Create SG Group
#-------------------------------------------------------------
resource "aws_security_group" "smtp_ses" {
  name        = "${var.environment_name}-smtp-ses"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Smtp incoming"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-smtp-ses", "Type", "SMTP-SES"))}"
}
