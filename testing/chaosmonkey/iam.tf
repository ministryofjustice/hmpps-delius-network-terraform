# Fetch local context, e.g. current account id for arn strings
data "aws_caller_identity" "current" {}

# Create a Service Role for AWS Batch to run under
data "template_file" "batch_assume_role_template" {
  template = "${file("${path.module}/templates/iam_policies/batch_assume_policy.tpl")}"

  vars {}
}

resource "aws_iam_role" "batch_service_role" {
  name = "${local.name_prefix}-batch-role"

  assume_role_policy = "${data.template_file.batch_assume_role_template.rendered}"
}

# Use existing managed iam policy for ECS instances - May want to copy and manage this separately
resource "aws_iam_role_policy_attachment" "batch_service_role_policy_attachment" {
  role       = "${aws_iam_role.batch_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# Create the EC2 Instance role ECS instances will run under
data "template_file" "ecs_assume_role_template" {
  template = "${file("${path.module}/templates/iam_policies/ecs_assume_policy.tpl")}"

  vars {}
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${local.name_prefix}-ecs-role"

  assume_role_policy = "${data.template_file.ecs_assume_role_template.rendered}"
}

# Use existing managed iam policy for ECS instances - May want to copy and manage this separately
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachement" {
  role       = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${local.name_prefix}-ecs-profile"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

# Create dedicated IAM Role and policy for Chaosmonkey batch job
data "template_file" "job_role_policy_template" {
  template = "${file("./templates/iam_policies/job_role_policy.tpl")}"

  vars { }
}

resource "aws_iam_role" "job_role" {
  name               = "${local.name_prefix}-job-role"
  assume_role_policy = "${data.template_file.ecs_assume_role_template.rendered}"
}

resource "aws_iam_role_policy" "job_policy" {
  name = "batch_sts_policy"
  role = "${aws_iam_role.job_role.name}"

  policy = "${data.template_file.job_role_policy_template.rendered}"
}