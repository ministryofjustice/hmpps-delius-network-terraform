# Host Security Group - with ssh inbound from bastion
# Defined here rather than in central security groups as it is standalone. Each task will have a dedicated sg
resource "aws_security_group" "oracle_observer_ecs_host_sg" {
  name        = "${local.name_prefix}-oracle_observer_ecscluster-private-sg"
  description = "Oracle Observer ECS Cluster Hosts Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-oracle-observer-ecscluster-private-sg" })
}

# ECS Cluster
resource "aws_ecs_cluster" "oracle_observer_ecs" {
  name = local.oracle_observer_ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(var.tags, { Name = local.oracle_observer_ecs_cluster_name })
}


# Host Launch Configuration
resource "aws_launch_configuration" "oracle_observer_ecs_host_lc" {
  name_prefix                 = "${local.name_prefix}-oracle-observer-ecscluster-private-asg"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.oracle_observer_ecs_host_profile.name
  image_id                    = data.aws_ami.ecs_ami.id
  instance_type               = var.ecs_instance_type

  security_groups = [
    aws_security_group.oracle_observer_ecs_host_sg.id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
  ]

  key_name         = data.terraform_remote_state.vpc.outputs.ssh_deployer_key

  lifecycle {
    create_before_destroy = true
  }
}

# Host ASG
resource "aws_autoscaling_group" "oracle_observer_ecs_asg" {
  name                 = "${local.name_prefix}-oracle-observer-ecscluster-private-asg"
  launch_configuration = aws_launch_configuration.oracle_observer_ecs_host_lc.id

  # Not setting desired count as that could cause scale in when deployment runs and lead to resource exhaustion
  max_size              = 1
  min_size              = 1
  protect_from_scale_in = true # scale-in is managed by ECS

  vpc_zone_identifier = local.private_subnet_ids

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name             = "${local.name_prefix}-oracle-cluster-ecscluster-private-asg"
      AmazonECSManaged = "" # Required when using ecs_capacity_provider for scaling
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
