terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.65"
}

####################################################
# DATA SOURCE MODULES FROM OTHER TERRAFORM BACKENDS
####################################################

#-------------------------------------------------------------
### Getting the current running account id
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}

#-------------------------------------------------------------
### Getting the common details
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
### Getting the efs details
#-------------------------------------------------------------
data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "natgateway/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the security groups details
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

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS ECS Centos master*"]
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

  owners = ["${data.terraform_remote_state.vpc.vpc_account_id}", "895523100917"] # MOJ
}

#-------------------------------------------------------------
### Getting ACM Cert
#-------------------------------------------------------------
data "aws_acm_certificate" "cert" {
  domain      = "*.${data.terraform_remote_state.vpc.public_zone_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

####################################################
# Locals
####################################################

locals {
  ami_id                       = "${data.aws_ami.ecs_ami.id}"
  application                  = "elasticsearch"
  efs_mount_path               = "/opt/es_backup"
  es_home_dir                  = "/usr/share/elasticsearch"
  cidr_block                   = "${data.terraform_remote_state.vpc.vpc_cidr_block}"
  vpc_id                       = "${data.terraform_remote_state.vpc.vpc_id}"
  account_id                   = "${data.terraform_remote_state.vpc.vpc_account_id}"
  sg_bastion_in_id             = "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"
  lb_security_groups           = ["${data.terraform_remote_state.security-groups.sg_monitoring_elb}"]
  common_name                  = "${local.short_environment_identifier}-elk"
  certificate_arn              = "${data.aws_acm_certificate.cert.arn}"
  environment                  = "${var.environment_type}"
  image_url                    = "${var.es_image_url}"
  allowed_cidr_block           = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  internal_domain              = "${data.terraform_remote_state.vpc.private_zone_name}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  external_domain              = "${data.terraform_remote_state.vpc.public_zone_name}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  containerport                = 9200
  service_desired_count        = "${var.es_service_desired_count}"
  region                       = "${var.region}"
  bastion_inventory            = "${var.bastion_inventory}"
  ssh_deployer_key             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  server_dns                   = "monitoring"
  eng_vpc_cidr                 = "${data.terraform_remote_state.vpc.eng_vpc_cidr}"
  port                         = 9200
  protocol                     = "HTTP"
  service_type                 = "logstash"
  registry_url                 = "mojdigitalstudio"
  docker_tag                   = "latest"

  natgateway_cidrs = [
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az1}/32",
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az2}/32",
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az3}/32",
  ]

  private_subnet_ids = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]

  public_subnet_ids = [
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az3}",
  ]

  efs_security_groups = [
    "${data.terraform_remote_state.security-groups.sg_mon_efs}",
  ]

  instance_security_groups = [
    "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.security-groups.sg_mon_efs}",
    "${data.terraform_remote_state.security-groups.sg_monitoring}",
    "${data.terraform_remote_state.security-groups.sg_elasticsearch}",
  ]

  elasticsearch_security_groups = [
    "${data.terraform_remote_state.security-groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.security-groups.sg_mon_efs}",
    "${data.terraform_remote_state.security-groups.sg_elasticsearch}",
  ]

  tags = "${data.terraform_remote_state.vpc.tags}"
}
