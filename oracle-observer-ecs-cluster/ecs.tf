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
  instance_type               = var.oracle_observer_ecs_instance_type

  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_in_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_out_id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id
  ]

  key_name         = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  user_data_base64 = base64encode(data.template_file.oracle_observer_ecs_host_userdata_template.rendered)

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

resource "aws_cloudwatch_log_group" "oracle_observer_log_group" {
  name = "/oracle-observer-ecs/run-observer-logs"
  retention_in_days = 14
}

resource "random_id" "container_id" {
  byte_length = 8
}

resource "aws_ecs_task_definition" "oracle_observer_task_definition" {
  family                   = "${local.name_prefix}-oracle-observer-task-definition"
  task_role_arn            = aws_iam_role.oracle_observer_task_role.arn
  execution_role_arn       = local.ecs_task_execution_role
  requires_compatibilities = ["EC2"]
  cpu                      = var.oracle_observer_cpu
  memory                   = var.oracle_observer_memory
  tags                     = merge(var.tags, { Name = "${local.name_prefix}-oracle-observer-task-definition" })
  container_definitions = jsonencode([{
    name  = "${local.name_prefix}-oracle-observer-container"
    image = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/oracle-dg-observer"
    hostname = "${local.name_prefix}-oracle-observer-container-${random_id.container_id.hex}"
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.oracle_observer_log_group.name
          awslogs-region = "${var.region}"
          awslogs-stream-prefix = "oracle-observer-ecs"
        }
    }
    environment = [
      {
        name  = "PASSWORD_PARAMETER_PATH"
        value = "${local.sys_password_path}"
      },
      {
        name  = "TNS_PRIMARYDB"
        value = "${data.terraform_remote_state.database_failover.outputs.tns_delius_primarydb}"
      },
      {
        name  = "TNS_STANDBYDB1"
        value = var.database_high_availability_count["delius"] >= 1 ? "${data.terraform_remote_state.database_failover.outputs.tns_delius_standbydb1}" : "NONE"
      },
      {
        name  = "TNS_STANDBYDB2"
        value = var.database_high_availability_count["delius"] >= 2 ? "${data.terraform_remote_state.database_failover.outputs.tns_delius_standbydb2}" : "NONE"
      }
    ]
  }])

  }

# Define an ECS Service which will attempt to run a single instance of the Oracle Data Guard Observer Docker image within the Cluster
  resource "aws_ecs_service" "oracle_observer_service" {
  name                               = "${local.name_prefix}-oracle-observer-service"
  cluster                            = aws_ecs_cluster.oracle_observer_ecs.arn
  task_definition                    = aws_ecs_task_definition.oracle_observer_task_definition.arn
  scheduling_strategy                = "DAEMON"
}