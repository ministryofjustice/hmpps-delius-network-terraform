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

  tags = merge(
    var.tags,
    {
      "Name" = "${local.name_prefix}-ecscluster-private-sg"
    },
  )
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

  tags = merge(
    var.tags,
    {
      "Name" = "${local.name_prefix}-ecsefs-private-sg"
    },
  )
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs" {
  name = "${local.name_prefix}-ecscluster-private-ecs"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
  tags = merge(var.tags, { Name = "${local.name_prefix}-ecscluster-private-ecs" })
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
  max_size = var.node_max_count
  min_size = var.node_min_count

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

  tags = concat(data.null_data_source.tags.*.outputs, [{
    key                 = "Name"
    value               = "${local.name_prefix}-ecscluster-private-asg"
    propagate_at_launch = true
  }])
}

# Autoscaling Policies and trigger alarms
resource "aws_autoscaling_policy" "ecs_host_scaleup" {
  name                   = "${local.name_prefix}-ecssclup-pri-asg"
  scaling_adjustment     = "1"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}

resource "aws_autoscaling_policy" "ecs_host_scaledown" {
  name                   = "${local.name_prefix}-ecsscldown-pri-asg"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ecs_scaleup_alarm" {
  alarm_name          = "${local.name_prefix}-ecssclup-cpu-cwa"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.ecs_scale_up_cpu_threshold
  alarm_actions       = [aws_autoscaling_policy.ecs_host_scaleup.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_scaleup_mem_alarm" {
  alarm_name          = "${local.name_prefix}-ecssclup-mem-cwa"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.ecs_scale_up_cpu_threshold
  alarm_actions       = [aws_autoscaling_policy.ecs_host_scaleup.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs.name
  }
}

# Scaling down must only happen if both cpu and mem reservations are below the threshold
resource "aws_cloudwatch_metric_alarm" "ecs_scaledown_alarm" {
  alarm_name          = "${local.name_prefix}-ecsscldown-cpu-cwa"
  alarm_description   = "ECS cluster scaling metric under threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  threshold           = "1"
  alarm_actions       = [aws_autoscaling_policy.ecs_host_scaledown.arn]

  metric_query {
    id          = "mq"
    expression  = "CEIL((cpu-${var.ecs_scale_down_cpu_threshold})/100)+CEIL((mem-${var.ecs_scale_down_mem_threshold})/100)"
    label       = "ECS Cluster CPU and Mem Reservations are BOTH Below Threshold for Scale Down"
    return_data = "true"
  }

  metric_query {
    id = "cpu"
    metric {
      metric_name = "CPUReservation"
      namespace   = "AWS/ECS"
      period      = "120"
      stat        = "Maximum"
      unit        = "Percent"
      dimensions = {
        ClusterName = aws_ecs_cluster.ecs.name
      }
    }
  }

  metric_query {
    id = "mem"
    metric {
      metric_name = "MemoryReservation"
      namespace   = "AWS/ECS"
      period      = "120"
      stat        = "Maximum"
      unit        = "Percent"
      dimensions = {
        ClusterName = aws_ecs_cluster.ecs.name
      }
    }
  }
}

