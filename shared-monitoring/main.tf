terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

#-------------------------------------------------------------
### Getting aws_caller_identity
#-------------------------------------------------------------
data "aws_caller_identity" "current" {}

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
}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

locals {
  availability_zones      = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]
  instance_type           = "t2.large"
  ebs_device_volume_size  = "2048"
  docker_image_tag        = "latest"
}
module "create_elastic_cluster" {
  source = "./elasticsearch-cluster"

  app_name                      = "elasticsearch-cluster"
  instance_type                 = "${local.instance_type}"
  ebs_device_volume_size        = "${local.ebs_device_volume_size}"
  docker_image_tag              = "${local.docker_image_tag}"
  availability_zones            = "${local.availability_zones}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  bastion_client_sg_id          = "${var.bastion_client_sg_id}"
  environment_identifier        = "${var.environment_identifier}"
  region                        = "${var.region}"
  terraform_remote_state_vpc    = "${data.terraform_remote_state.vpc}"
  route53_sub_domain            = "${var.route53_sub_domain}"
  amazon_ami_id                 = "${data.aws_ami.amazon_ami.id}"
}

module "create_monitoring_instance" {
  source = "./monitoring-server"

  app_name                      = "monitoring-server"
  terraform_remote_state_vpc    = "${data.terraform_remote_state.vpc}"

  amazon_ami_id                 = "${data.aws_ami.amazon_ami.id}"
  whitelist_monitoring_ips      = "${var.whitelist_monitoring_ips}"
  elasticsearch_cluster         = "${module.create_elastic_cluster}"
  instance_type                 = "${local.instance_type}"
  ebs_device_volume_size        = "${local.ebs_device_volume_size}"
  docker_image_tag              = "${local.docker_image_tag}"
  availability_zones            = "${local.availability_zones}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  bastion_client_sg_id          = "${var.bastion_client_sg_id}"
  environment_identifier        = "${var.environment_identifier}"
  region                        = "${var.region}"
  route53_sub_domain            = "${var.route53_sub_domain}"
  route53_domain_private        = "${var.route53_domain_private}"
  route53_hosted_zone_id        = "${var.route53_hosted_zone_id}"
  public_ssl_arn                = "${var.public_ssl_arn}"
}