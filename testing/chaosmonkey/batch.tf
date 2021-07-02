# Create a dedicated security group with no ingress for the batch compute environment
# Requires egress for pulling images from container registry and connection to p-nomis and delius endpoints
resource "aws_security_group" "ce_sg" {
  name        = "${local.name_prefix}-testing-out"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Chaosmonkey Testing Out"
  tags = merge(
    var.tags,
    {
      "Name" = "${local.name_prefix}-testing-out"
      "Type" = "Private"
    },
  )
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "batch_ce" {
  compute_environment_name_prefix = "${local.name_prefix}-testing-ce"

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_profile.arn
    ec2_key_pair  = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
    instance_type = var.ce_instances

    max_vcpus = var.ce_max_vcpu
    min_vcpus = var.ce_min_vcpu

    security_group_ids = [aws_security_group.ce_sg.id]

    subnets = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
    ]

    type = "EC2"

    tags = merge(
    var.tags,
    {
      "Name" = "${local.name_prefix}-batch"
    },

  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role_policy_attachment]

  # AWS Batch manages the desired_vcpus value dynamically - don't try and adjust
  lifecycle {
    ignore_changes        = [compute_resources.0.desired_vcpus]
    create_before_destroy = true
  }
}

resource "aws_batch_job_queue" "batch_queue" {
  name  = "${local.name_prefix}-testing-queue"
  state = var.ce_queue_state

  # This is a standalone CE with a single queue - therefore priority is fixed
  priority             = 1
  compute_environments = [aws_batch_compute_environment.batch_ce.arn]
}

