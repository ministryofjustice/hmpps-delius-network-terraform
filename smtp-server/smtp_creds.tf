###########################
#Create IAM user for smtp
###########################

resource "aws_iam_user" "ses" {
  name             = "${var.short_environment_identifier}-ses-smtp-user"
  path             = "/"
  force_destroy    = true
  tags             = "${var.tags}"
}

####Create group
resource "aws_iam_group" "ses_group" {
  name   = "${var.short_environment_identifier}-ses-smtp-group"
}

####Create policy
resource "aws_iam_policy" "ses" {
  name             = "AmazonSesSendingAccess"

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
  group         = "${aws_iam_group.ses_group.name}"
  policy_arn    = "${aws_iam_policy.ses.arn}"
}

#Attach user to group
resource "aws_iam_group_membership" "ses_group_membership" {
  name       = "${var.short_environment_identifier}-ses-smtp-group-membership"
  group      = "${aws_iam_group.ses_group.name}"

  users = [
    "${aws_iam_user.ses.name}",
  ]
 }

locals {
    ses_iam_user      =  "${aws_iam_user.ses.id}"
}
