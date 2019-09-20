resource "aws_security_group" "amazonmq_in" {
  name        = "${var.environment_name}-delius-core-${var.spg_app_name}-amazonmq-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "amazonmq incoming"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}_${var.spg_app_name}_amazonmq_in", "Type", "API"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# spg_amazonmq_in
output "sg_amazonmq_in" {
  value = "${aws_security_group.amazonmq_in.id}"
}