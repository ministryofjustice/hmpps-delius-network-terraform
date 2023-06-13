# ECS Host Role
resource "aws_iam_role" "oracle_observer_ecs_host_role" {
  name               = "${local.name_prefix}-oracle-observer-ecshost-private-iam"
  assume_role_policy = data.template_file.oracle_observer_ecs_assume_role_template.rendered
}

# ECS Host Policies
resource "aws_iam_role_policy" "oracle_observer_ecs_host_role_policy" {
  name = "${local.name_prefix}-ecshost-private-iam"
  role = aws_iam_role.oracle_observer_ecs_host_role.name

  policy = data.template_file.oracle_observer_ecs_host_role_policy_template.rendered
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role = aws_iam_role.oracle_observer_ecs_host_role.name
}

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

# Task execution role for pulling the image and writing cloudwatch logs
resource "aws_iam_role" "oracle_observer_ecs_exec_role" {
  name               = "${local.name_prefix}-oracle-observer-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "oracle_observer_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "oracle_observer_exec_policy" {
  name   = "${local.name_prefix}-oracle-observer-ecs-exec-policy"
  policy = data.aws_iam_policy_document.oracle_observer_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "oracle_observer_exec_policy_attachment" {
  role       = aws_iam_role.oracle_observer_ecs_exec_role.name
  policy_arn = aws_iam_policy.oracle_observer_exec_policy.arn
}