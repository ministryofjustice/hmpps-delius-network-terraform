# Load in VPC state data for subnet placement
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

# Load in VPC security groups to reference bastion ssh inbound group for ecs hosts
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

# Get current context for things like account id
data "aws_caller_identity" "current" {
}

# Search for ami id
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  # Amazon Linux 2 optimised ECS instance
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }

  # correct arch
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  # Owned by Amazon
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Templates
data "template_file" "ecs_assume_role_template" {
  template = file("${path.module}/templates/iam/ecs-host-assumerole-policy.tpl")
  vars = {}
}

data "template_file" "ecs_host_role_policy_template" {
  template = file("${path.module}/templates/iam/ecs-host-role-policy.tpl")
  vars     = {}
}

# Host userdata template
data "template_file" "ecs_host_userdata_template" {
  template = file("${path.module}/templates/ec2/ecs-host-userdata.tpl")

  vars = {
    ecs_cluster_name         = local.ecs_cluster_name
    region                   = var.region
    efs_sg                   = aws_security_group.ecs_efs_sg.id
    log_group_name           = "${var.environment_name}/shared-ecs-cluster"
  }
}
