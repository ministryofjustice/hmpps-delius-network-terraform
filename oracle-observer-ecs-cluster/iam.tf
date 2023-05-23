# ECS Host Profile
resource "aws_iam_instance_profile" "oracle_observer_ecs_host_profile" {
  name = "${local.name_prefix}-oracle-observer-ecscluster-private-iam"
  role = aws_iam_role.oracle_observer_ecs_host_role.name
}

# Observer Task Role
resource "aws_iam_role" "oracle_observer_task_role" {
  name               = "${local.name_prefix}-oracle-observer-task-role"
  assume_role_policy = data.template_file.oracle_observer_task_assumerole_policy_template.rendered
}

resource "aws_iam_role_policy" "oracle_observer_task_policy" {
  name = "${local.name_prefix}-task-policy"
  role = aws_iam_role.oracle_observer_task_role.name

  policy = data.template_file.oracle_observer_task_policy_template.rendered
}