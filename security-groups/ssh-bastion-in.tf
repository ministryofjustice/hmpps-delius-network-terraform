resource "aws_security_group" "ssh_bastion_in" {
  name        = "${var.environment_name}-ssh-bastion-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "SSH bastion in"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-ssh-bastion-in", "Type", "SSH"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_ssh_bastion_in_id" {
  value = "${aws_security_group.ssh_bastion_in.id}"
}

resource "aws_security_group_rule" "ssh_bastion_in" {
  security_group_id = "${aws_security_group.ssh_bastion_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [ "${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}" ]
  description       = "TF - ssh_bastion_in"
}

#to allow sshing to docker containers with port 2222 exposed on the docker host
resource "aws_security_group_rule" "alt_ssh_bastion_in" {
  security_group_id = "${aws_security_group.ssh_bastion_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "2222"
  to_port           = "2222"
  cidr_blocks       = [ "${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}" ]
  description       = "TF - alt_ssh_bastion_in"
}

resource "aws_security_group_rule" "ssh_eng_jenkins_in" {
  security_group_id = "${aws_security_group.ssh_bastion_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [ "${data.terraform_remote_state.vpc.eng_vpc_cidr}" ]
  description       = "TF - ssh_eng_jenkins_in"
}
