resource "aws_security_group" "ssh_bastion_in" {
  name        = "${var.environment_name}-ssh-bastion-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "SSH bastion in"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-ssh-bastion-in"
      "Type" = "SSH"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_ssh_bastion_in_id" {
  value = aws_security_group.ssh_bastion_in.id
}

resource "aws_security_group_rule" "ssh_bastion_in" {
  security_group_id = aws_security_group.ssh_bastion_in.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks = [values(
    data.terraform_remote_state.vpc.outputs.bastion_vpc_public_cidr,
  )]
  description = "TF - ssh_bastion_in"
}

#to allow sshing to docker containers with port 2222 exposed on the docker host
resource "aws_security_group_rule" "alt_ssh_bastion_in" {
  security_group_id = aws_security_group.ssh_bastion_in.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "2222"
  to_port           = "2222"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks = [values(
    data.terraform_remote_state.vpc.outputs.bastion_vpc_public_cidr,
  )]
  description = "TF - alt_ssh_bastion_in"
}

resource "aws_security_group_rule" "ssh_eng_jenkins_in" {
  security_group_id = aws_security_group.ssh_bastion_in.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  cidr_blocks = [data.terraform_remote_state.vpc.outputs.eng_vpc_cidr]
  description = "TF - ssh_eng_jenkins_in"
}

resource "aws_security_group_rule" "internal_in_ping" {
  security_group_id = aws_security_group.ssh_bastion_in.id
  type              = "ingress"
  protocol          = "icmp"
  from_port         = "8"
  to_port           = "0"
  cidr_blocks       = ["10.0.0.0/8"]
  description       = "Internal Ping in all"
}

resource "aws_security_group_rule" "out_ping" {
  security_group_id = aws_security_group.ssh_bastion_in.id
  type              = "egress"
  protocol          = "icmp"
  from_port         = "8"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Ping out all"
}

