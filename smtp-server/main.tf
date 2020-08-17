####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the vpc details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

####################################################
# Locals
####################################################

locals {
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_bastion_in        = data.terraform_remote_state.security-groups.outputs.sg_ssh_bastion_in_id
  sg_smtp_ses          = data.terraform_remote_state.security-groups.outputs.sg_smtp_ses
  sg_https_out         = data.terraform_remote_state.security-groups.outputs.sg_https_out
  sg_iaps_api_in       = data.terraform_remote_state.security-groups.outputs.sg_iaps_api_in
  bastion_inventory    = var.bastion_inventory
  private_zone_id      = data.terraform_remote_state.vpc.outputs.private_zone_id
  internal_domain      = data.terraform_remote_state.vpc.outputs.private_zone_name
  app_name             = "smtp"
  ec2_policy_file      = "ec2_policy.json"
  ec2_role_policy_file = "policies/ec2.json"
  environment_name     = var.environment_type
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
}

#-------------------------------------------------------------
### IAM Policy template file
#-------------------------------------------------------------
data "template_file" "iam_policy_app" {
  template = file("${path.module}/${local.ec2_role_policy_file}")
}

#-------------------------------------------------------------
### EC2 Role
#-------------------------------------------------------------
module "iam_app_role" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/role?ref=terraform-0.12"
  policyfile = local.ec2_policy_file
  rolename   = "${var.short_environment_identifier}-${local.app_name}"
}

#-------------------------------------------------------------
### IAM Instance profile
#-------------------------------------------------------------
module "iam_instance_profile" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/instance_profile?ref=terraform-0.12"
  role   = module.iam_app_role.iamrole_name
}

#-------------------------------------------------------------
### IAM Policy
#-------------------------------------------------------------
module "iam_app_policy" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/iam/rolepolicy?ref=terraform-0.12"
  policyfile = data.template_file.iam_policy_app.rendered
  rolename   = module.iam_app_role.iamrole_name
}

#-------------------------------------------------------------
### Userdata template
#-------------------------------------------------------------

data "template_file" "postfix_user_data" {
  template = file("user_data/bootstrap.sh")

  vars = {
    app_name             = local.app_name
    bastion_inventory    = local.bastion_inventory
    private_domain       = local.internal_domain
    private_zone_id      = local.private_zone_id
    account_id           = data.terraform_remote_state.vpc.outputs.vpc_account_id
    environment_name     = local.environment_name
    mail_hostname        = "${local.app_name}.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    mail_domain          = data.terraform_remote_state.vpc.outputs.public_zone_name
    mail_network         = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    ses_iam_user         = local.ses_iam_user
    env_identifier       = var.short_environment_identifier
    short_env_identifier = var.short_environment_identifier
    smtp_log_group       = aws_cloudwatch_log_group.smtp_log_group.name
    region               = var.region
  }
}

#-------------------------------------------------------------
### Create instance
#-------------------------------------------------------------

resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${var.short_environment_name}-smtp-launch-cfg-"
  image_id             = data.aws_ami.amazon_ami.id
  iam_instance_profile = module.iam_instance_profile.iam_instance_name
  instance_type        = var.smtp_instance_type
  security_groups = [
    local.sg_bastion_in,
    local.sg_smtp_ses,
    local.sg_https_out,
  ]
  enable_monitoring           = "true"
  associate_public_ip_address = false
  key_name                    = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  user_data                   = data.template_file.postfix_user_data.rendered
  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "null_data_source" "tags" {
  count = length(keys(var.tags))
  inputs = {
    key                 = element(keys(var.tags), count.index)
    value               = element(values(var.tags), count.index)
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.environment_name}-smtp"
  vpc_zone_identifier = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  launch_configuration = aws_launch_configuration.launch_cfg.id
  min_size             = var.instance_count
  max_size             = var.instance_count
  desired_capacity     = var.instance_count
  tags = concat(data.null_data_source.tags.*.outputs, [{
    key                 = "Name"
    value               = "${var.environment_name}-smtp"
    propagate_at_launch = "true"
  }])
  lifecycle {
    create_before_destroy = true
  }
}

#smtp lb attachment
resource "aws_autoscaling_attachment" "smtp_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_elb.smtp_lb.id
}

#Create log group
resource "aws_cloudwatch_log_group" "smtp_log_group" {
  name              = "${var.short_environment_identifier}/smtp_logs"
  retention_in_days = "14"
  tags = merge(
    var.tags,
    {
      "Name" = "smtp_logs"
    },
  )
}

#-------------------------------------------------------------
### Create SG Rules
#-------------------------------------------------------------

### SMTP in
resource "aws_security_group_rule" "smtp-in" {
  security_group_id = local.sg_smtp_ses
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "25"
  to_port           = "25"
  self              = "true"
  description       = "TF - SMTP In"
}

resource "aws_security_group_rule" "iaps-smtp-in" {
  security_group_id        = local.sg_smtp_ses
  source_security_group_id = local.sg_iaps_api_in
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "25"
  to_port                  = "25"
  description              = "IAPS SMTP In"
}

### SMTP out
resource "aws_security_group_rule" "smtp-out" {
  security_group_id = local.sg_smtp_ses
  type              = "egress"
  protocol          = "tcp"
  from_port         = "25"
  to_port           = "25"
  self              = "true"
  description       = "TF - SMTP Out"
}

### SES out
resource "aws_security_group_rule" "ses-out" {
  security_group_id = local.sg_smtp_ses
  type              = "egress"
  protocol          = "tcp"
  from_port         = "587"
  to_port           = "587"
  description       = "TF - SES out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

### HTTPS out
resource "aws_security_group_rule" "https-out" {
  security_group_id = local.sg_https_out
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  description       = "TF - HTTPS out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

### HTTP out
resource "aws_security_group_rule" "http-out" {
  security_group_id = local.sg_https_out
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  description       = "TF - HTTP out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
