resource "aws_security_group" "monitoring_sg" {
  name        = "${var.environment_identifier}-monitoring-elk"
  description = "security group for ${var.environment_identifier}-monitoring"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-elk"))}"
}

resource "aws_security_group" "monitoring_elb_sg" {
  name        = "${var.environment_identifier}-monitoring-elk-elb"
  description = "security group for ${var.environment_identifier}-monitoring-elk-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-elk-elb"))}"
}

resource "aws_security_group" "monitoring_client_sg" {
  name        = "${var.environment_identifier}-monitoring-elk-client"
  description = "security group for ${var.environment_identifier}-elasticsearch"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-elk-client"))}"
}

resource "aws_security_group" "elasticsearch_sg" {
  name        = "${var.environment_identifier}-monitoring-elasticsearch"
  description = "security group for ${var.environment_identifier}-elasticsearch"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-elasticsearch"))}"
}

resource "aws_security_group" "mon_efs" {
  name        = "${var.environment_identifier}-monitoring-efs"
  description = "security group for ${var.environment_identifier}-efs"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-efs"))}"
}

resource "aws_security_group" "mon_jenkins" {
  name        = "${var.environment_identifier}-monitoring-jenkins"
  description = "security group for ${var.environment_identifier}-jenkins"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_identifier}-monitoring-jenkins"))}"
}

# outputs
output "sg_monitoring" {
  value = "${aws_security_group.monitoring_sg.id}"
}

output "sg_monitoring_elb" {
  value = "${aws_security_group.monitoring_elb_sg.id}"
}

output "sg_monitoring_client" {
  value = "${aws_security_group.monitoring_client_sg.id}"
}

output "sg_elasticsearch" {
  value = "${aws_security_group.elasticsearch_sg.id}"
}

output "sg_mon_efs" {
  value = "${aws_security_group.mon_efs.id}"
}

output "sg_mon_jenkins" {
  value = "${aws_security_group.mon_jenkins.id}"
}
