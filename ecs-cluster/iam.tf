# ECS Host Role template
data "template_file" "ecs_assume_role_template" {
  template = "${file("./templates/iam/ecs-host-assumerole-policy.tpl")}"
  vars     = {}
}

data "template_file" "ecs_host_role_policy_template" {
  template = "${file("./templates/iam/ecs-host-role-policy.tpl")}"
  vars     = {}
}

# ECS Host Role
resource "aws_iam_role" "ecs_host_role" {
  name               = "${var.project_name_abbreviated}-${var.project_name}-ecshost-private-iam"
  assume_role_policy = "${data.template_file.ecs_assume_role_template.rendered}"
}

# ECS Host Policy
resource "aws_iam_role_policy" "ecs_host_role_policy" {
  name = "${var.project_name_abbreviated}-${var.project_name}-ecshost-private-iam"
  role = "${aws_iam_role.ecs_host_role.name}"

  policy = "${data.template_file.ecs_host_role_policy_template.rendered}"
}

# ECS Host Profile
resource "aws_iam_instance_profile" "ecs_host_profile" {
  name = "${var.project_name_abbreviated}-${var.project_name}-ecscluster-private-iam"
  role = "${aws_iam_role.ecs_host_role.name}"
}
