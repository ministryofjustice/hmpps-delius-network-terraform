terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################
#-------------------------------------------------------------
### Getting the vpc details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the sg details
#-------------------------------------------------------------
data "terraform_remote_state" "security-groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}
#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
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
    name = "root-device-type"
    values = ["ebs"]
  }
}

####################################################
# Locals
####################################################

locals {
  vpc_id               = "${data.terraform_remote_state.vpc.vpc_id}"
  sg_bastion_in        = "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}"
  sg_smtp_ses          = "${data.terraform_remote_state.security-groups.sg_smtp_ses}"
  sg_https_out         = "${data.terraform_remote_state.security-groups.sg_https_out}"
  bastion_inventory    = "${var.bastion_inventory}"
  private_zone_id      = "${data.terraform_remote_state.vpc.private_zone_id}"
  internal_domain      = "${data.terraform_remote_state.vpc.private_zone_name}"
  app_name             = "smtp"
  ec2_policy_file      = "ec2_policy.json"
  ec2_role_policy_file = "policies/ec2.json"
  environment_name     = "${var.environment_type}"
}


#-------------------------------------------------------------
### IAM Policy template file
#-------------------------------------------------------------
data "template_file" "iam_policy_app" {
  template = "${file("${path.module}/${local.ec2_role_policy_file}")}"
}

#-------------------------------------------------------------
### EC2 Role
#-------------------------------------------------------------
module "iam_app_role" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//role"
  policyfile    = "${local.ec2_policy_file}"
  rolename      = "${var.short_environment_identifier}-${local.app_name}"
}

#-------------------------------------------------------------
### IAM Instance profile
#-------------------------------------------------------------
module "iam_instance_profile" {
  source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//instance_profile"
  role      = "${module.iam_app_role.iamrole_name}"
}


#-------------------------------------------------------------
### IAM Policy
#-------------------------------------------------------------
module "iam_app_policy" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//rolepolicy"
  policyfile    = "${data.template_file.iam_policy_app.rendered}"
  rolename      = "${module.iam_app_role.iamrole_name}"
}


#-------------------------------------------------------------
### Userdata template
#-------------------------------------------------------------

data "template_file" "postfix_user_data" {
  template = "${file("user_data/bootstrap.sh")}"

  vars {
    app_name              = "${local.app_name}"
    bastion_inventory     = "${local.bastion_inventory}"
    private_domain        = "${data.terraform_remote_state.vpc.private_zone_name}"
    account_id            = "${data.terraform_remote_state.vpc.vpc_account_id}"
    environment_name      = "${local.environment_name}"
    mail_hostname         = "mail.${data.terraform_remote_state.vpc.public_zone_name}"
    mail_domain           = "${data.terraform_remote_state.vpc.public_zone_name}"
    mail_network          = "${data.terraform_remote_state.vpc.vpc_cidr_block}"
    ses_iam_user          = "${local.ses_iam_user}"
    env_identifier        = "${var.short_environment_identifier}"
    short_env_identifier  = "${var.short_environment_identifier}"
  }
}

#-------------------------------------------------------------
### Create instance
#-------------------------------------------------------------
module "create-ec2-instance" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ec2"
  ami_id                      = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"
  iam_instance_profile        = "${module.iam_instance_profile.iam_instance_name}"
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = "${data.template_file.postfix_user_data.rendered}"
  CreateSnapshot              = true
  key_name                    = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  app_name                    = "${var.short_environment_identifier}-${local.app_name}"
  tags                        = "${data.terraform_remote_state.vpc.tags}"


  vpc_security_group_ids = [
    "${local.sg_bastion_in}",
    "${local.sg_smtp_ses}",
    "${local.sg_https_out}",
  ]
}

#-------------------------------------------------------------
### Create internal dns record
#-------------------------------------------------------------

resource "aws_route53_record" "instance" {
  zone_id      = "${local.private_zone_id}"
  name         = "${local.app_name}.${local.internal_domain}"
  type         = "A"
  ttl          = "300"
  records      = ["${module.create-ec2-instance.private_ip}"]
}


#-------------------------------------------------------------
### Create SG Rules
#-------------------------------------------------------------

### SMTP in
resource "aws_security_group_rule" "smtp-in" {
  security_group_id        = "${local.sg_smtp_ses}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "25"
  to_port                  = "25"
  self                     = "true"
  description              = "TF - SMTP In"
}

### SMTP out
resource "aws_security_group_rule" "smtp-out" {
  security_group_id        = "${local.sg_smtp_ses}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "25"
  to_port                  = "25"
  self                     = "true"
  description              = "TF - SMTP Out"
}

### SES out
resource "aws_security_group_rule" "ses-out" {
  security_group_id        = "${local.sg_smtp_ses}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "587"
  to_port                  = "587"
  description              = "TF - SES out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}



### HTTPS out
resource "aws_security_group_rule" "https-out" {
  security_group_id        = "${local.sg_https_out}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "TF - HTTPS out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

### HTTP out
resource "aws_security_group_rule" "http-out" {
  security_group_id        = "${local.sg_https_out}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "80"
  to_port                  = "80"
  description              = "TF - HTTP out"
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
