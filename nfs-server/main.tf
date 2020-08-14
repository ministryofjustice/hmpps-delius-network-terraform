#-------------------------------------------------------------
### Getting aws_caller_identity
#-------------------------------------------------------------
data "aws_caller_identity" "current" {
}

#-------------------------------------------------------------
### Getting the current vpc
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
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

locals {
  availability_zones = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1-availability_zone,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2-availability_zone,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3-availability_zone,
  ]
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]

  private_cidr_blocks = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az2-cidr_block,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az3-cidr_block,
  ]
  bastion_origin_sgs = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
  ]

  instance_type          = "t2.large"
  ebs_device_volume_size = "2048"
  route53_sub_domain     = "${var.environment_type}.${var.project_name}"
  account_id             = data.aws_caller_identity.current.account_id
  public_ssl_arn         = data.terraform_remote_state.vpc.outputs.public_ssl_arn

  example_instance_count = 0
}

module "nfs-server" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/nfs-server?ref=terraform-0.12"

  region                       = var.region
  remote_state_bucket_name     = var.remote_state_bucket_name
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier
  tags                         = var.tags
  availability_zones           = local.availability_zones
  private_subnet_ids           = local.private_subnet_ids
  instance_type                = local.instance_type
  nfs_volume_size              = local.ebs_device_volume_size

  bastion_origin_sgs = local.bastion_origin_sgs
  bastion_inventory  = var.bastion_inventory

  private-cidr       = local.private_cidr_blocks
  route53_sub_domain = local.route53_sub_domain
}

### ------------------------------------
# This below is an example of how to connect to the nfs service
### ------------------------------------

data "aws_ami" "example_instance_ami" {
  count = local.example_instance_count

  most_recent = true
  owners      = ["895523100917"]

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
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "template_file" "example_client_user_data" {
  count = local.example_instance_count

  template = file("${path.module}/user_data/client.sh")

  vars = {
    // Variables Below are for bootstrapping
    app_name             = "nfs-client"
    env_identifier       = var.environment_identifier
    short_env_identifier = var.short_environment_identifier
    route53_sub_domain   = local.route53_sub_domain
    private_domain       = data.terraform_remote_state.vpc.outputs.private_zone_name
    account_id           = data.terraform_remote_state.vpc.outputs.vpc_account_id
    internal_domain      = data.terraform_remote_state.vpc.outputs.private_zone_name
    bastion_inventory    = var.bastion_inventory
    nfs_mount_dir        = "/srv/data"
  }
}

resource "aws_security_group_rule" "nfs_example_http_out" {
  count = local.example_instance_count

  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nfs_example_out[0].id
  to_port           = 80
  type              = "egress"

  description = "${var.environment_identifier}-nfs-client-http-out"

  cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
}

resource "aws_security_group_rule" "nfs_example_https_out" {
  count = local.example_instance_count

  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nfs_example_out[0].id
  to_port           = 443
  type              = "egress"

  description = "${var.environment_identifier}-nfs-client-https-out"

  cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
}

resource "aws_security_group" "nfs_example_out" {
  count = local.example_instance_count

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  description = "${var.environment_identifier}-nfs-client-instance-out"
  name        = "${var.environment_identifier}-nfs-client-instance-out"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_identifier}-nfs-client-instance-out"
    },
  )
}

resource "aws_instance" "nfs_example_client" {
  count         = local.example_instance_count
  ami           = data.aws_ami.example_instance_ami[0].id
  instance_type = "t2.micro"

  subnet_id = local.private_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.nfs_example_out[0].id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    module.nfs-server.nfs_client_sg_id,
  ]

  user_data = data.template_file.example_client_user_data[0].rendered

  key_name = data.terraform_remote_state.vpc.outputs.ssh_deployer_key

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_identifier}-nfs-example-client" },
  )
}

