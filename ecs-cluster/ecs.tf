# Host Security Group - with ssh inbound from bastion

# Host userdata template

# ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name_abbreviated}-${var.project_name}-ecscluster-private-ecs"
}

# Host ASG


# Host Launch Configuration

