# Host Security Group - with ssh inbound from bastion
# Defined here rather than in central security groups as it is standalone. Each task will have a dedicated sg
resource "aws_security_group" "ecs_host_sg" {
  name        = "${local.name_prefix}-ecscluster-private-sg"
  description = "Shared ECS Cluster Hosts Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-ecscluster-private-sg" })
}

# Security Group for docker EFS volumes used for persistent storage
resource "aws_security_group" "ecs_efs_sg" {
  name        = "${local.name_prefix}-ecsefs-private-sg"
  description = "Shared ECS Cluster EFS Volumes Security Group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    # TLS (change to whatever ports you need)
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_host_sg.id]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${local.name_prefix}-ecsefs-private-sg" })
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name = local.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(var.tags, { Name = local.ecs_cluster_name })
}

# Create a private service namespace to allow tasks to discover & communicate with each other
# without using load balancers, or building per env fqdns
resource "aws_service_discovery_private_dns_namespace" "ecs_namespace" {
  name        = var.ecs_cluster_namespace_name
  description = "Private namespace for shared ECS Cluster tasks"
  vpc         = data.terraform_remote_state.vpc.outputs.vpc_id
}

# Host Launch Configuration
resource "aws_launch_configuration" "ecs_host_lc" {
  name_prefix                 = "${local.name_prefix}-ecscluster-private-asg"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ecs_host_profile.name
  image_id                    = data.aws_ami.ecs_ami.id
  instance_type               = var.ecs_instance_type

  security_groups = [
    aws_security_group.ecs_host_sg.id,
    aws_security_group.ecs_efs_sg.id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
  ]

  user_data_base64 = base64encode(data.template_file.ecs_host_userdata_template.rendered)
  key_name         = data.terraform_remote_state.vpc.outputs.ssh_deployer_key

  lifecycle {
    create_before_destroy = true
  }
}

# Host ASG
resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "${local.name_prefix}-ecscluster-private-asg"
  launch_configuration = aws_launch_configuration.ecs_host_lc.id

  # Not setting desired count as that could cause scale in when deployment runs and lead to resource exhaustion
  max_size              = var.node_max_count
  min_size              = var.node_min_count
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
      Name             = "${local.name_prefix}-ecscluster-private-asg"
      AmazonECSManaged = "" # Required when using ecs_capacity_provider for scaling
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${local.name_prefix}-ecscluster-private-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = var.ecs_cluster_target_capacity
      maximum_scaling_step_size = 10
    }
  }
  tags = merge(var.tags, { Name = "${local.name_prefix}-ecscluster-private-capacity-provider" })
}
