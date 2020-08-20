locals {
  ses_iam_user       = aws_iam_user.ses.id
  ses_key_id_param   = aws_ssm_parameter.ses_access_key.id
  ses_password_param = aws_ssm_parameter.ses_password.id
}

###########################
#Create IAM user for smtp
###########################

resource "aws_iam_user" "ses" {
  name          = "${var.short_environment_identifier}-ses-smtp-user"
  path          = "/"
  force_destroy = true
  tags          = var.tags
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.ses.name
}

####Create group
resource "aws_iam_group" "ses_group" {
  name = "${var.short_environment_identifier}-ses-smtp-group"
}

####Create policy
resource "aws_iam_policy" "ses" {
  name = "${var.short_environment_identifier}-ses-policy"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
      "Effect": "Allow",
      "Action": "ses:SendRawEmail",
      "Resource": "*"
    }
  ]
}
EOF

}

####Attach policy to group
resource "aws_iam_group_policy_attachment" "ses_group_attach" {
  group      = aws_iam_group.ses_group.name
  policy_arn = aws_iam_policy.ses.arn
}

#Attach user to group
resource "aws_iam_group_membership" "ses_group_membership" {
  name  = "${var.short_environment_identifier}-ses-smtp-group-membership"
  group = aws_iam_group.ses_group.name

  users = [
    aws_iam_user.ses.name,
  ]
}

# Add to SES Creds to SSM
resource "aws_ssm_parameter" "ses_access_key" {
  name        = "${aws_iam_user.ses.id}-access-key-id"
  description = "SMTP User for SES"
  type        = "String"
  value       = aws_iam_access_key.smtp_user.id
  tags        = var.tags
}

resource "aws_ssm_parameter" "ses_password" {
  name        = "${aws_iam_user.ses.id}-ses-password"
  description = "SMTP Password for SES"
  type        = "SecureString"
  value       = aws_iam_access_key.smtp_user.ses_smtp_password_v4
  tags        = var.tags
}
