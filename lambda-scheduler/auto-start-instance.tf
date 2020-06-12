#-------------------------------------------------------------
### Userdata template
#-------------------------------------------------------------

data "template_file" "autostop_user_data" {
  template = "${file("user_data/bootstrap.sh")}"

  vars {
    app_name              = "${local.app_name}"
    bastion_inventory     = "${var.bastion_inventory}"
    private_domain        = "${local.internal_domain}"
    account_id            = "${data.terraform_remote_state.vpc.vpc_account_id}"
    environment_name      = "${var.environment_name}"
    env_identifier        = "${local.environment_identifier}"
    short_env_identifier  = "${local.short_environment_identifier}"
    region                = "${var.region}"
  }
}


resource "aws_instance" "autostop" {
  ami                         = "${data.aws_ami.amazon_ami.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"
  associate_public_ip_address = false
  key_name                    = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile        = "${module.iam_instance_profile.iam_instance_name}"
  user_data                   = "${data.template_file.autostop_user_data.rendered}"
  tags                        = "${merge(local.tags, map("Name", "${var.environment_name}-auto-stop"))}"

  vpc_security_group_ids = [
    "${local.sg_bastion_in}",
    "${local.sg_https_out}",
  ]
  root_block_device = {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}


#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------
data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
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
  owners   = ["895523100917"]
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
  rolename      = "${local.short_environment_identifier}-${local.app_name}"
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
