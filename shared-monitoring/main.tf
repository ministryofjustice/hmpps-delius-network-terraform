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
    values = ["HMPPS Base Docker Centos master *"]
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

#-------------------------------------------------------------
### Getting the bastion vpc
#-------------------------------------------------------------
data "terraform_remote_state" "bastion_remote_vpc" {
  backend = "s3"

  config {
    bucket   = "${data.terraform_remote_state.vpc.bastion_remote_state_bucket_name}"
    key      = "bastion-vpc/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${data.terraform_remote_state.vpc.bastion_role_arn}"
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

locals {
  availability_zones      = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-availability_zone}",
  ]
  private_subnet_ids      = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}"
  ]

  public_subnet_ids       = [
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az3}"
  ]

  bastion_origin_sgs      = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}"
  ]

  instance_type           = "t2.large"
  ebs_device_volume_size  = "2048"
  docker_image_tag        = "latest"
  route53_sub_domain      = "${var.environment_type}.${var.project_name}"
  account_id              = "${data.aws_caller_identity.current.account_id}"
  public_ssl_arn          = "${data.terraform_remote_state.vpc.public_ssl_arn}"

  share_name              = "${var.environment_type}_es_backup"
  backup_mount            = "/opt/es_backups"
}

module "create_elasticseach_efs_backup_share" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//efs"

  share_name        = "${local.share_name}"
  zone_id           = "${data.terraform_remote_state.vpc.private_zone_id}"
  domain            = "${data.terraform_remote_state.vpc.private_zone_name}"
  subnets           = "${local.private_subnet_ids}"
  security_groups   = ["${module.create_elastic_cluster.elasticsearch_cluster_sg_client_id}"]
  tags              = "${var.tags}"
}

module "create_elastic_cluster" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//components/monitoring/elasticsearch-cluster"

  app_name                      = "es-clust"
  instance_type                 = "${local.instance_type}"
  ebs_device_volume_size        = "${local.ebs_device_volume_size}"
  docker_image_tag              = "${local.docker_image_tag}"
  availability_zones            = "${local.availability_zones}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  environment_identifier        = "${var.environment_identifier}"
  region                        = "${var.region}"
  route53_sub_domain            = "${local.route53_sub_domain}"
  amazon_ami_id                 = "${data.aws_ami.amazon_ami.id}"
  bastion_origin_cidr           = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_cidr}"
  bastion_origin_sgs            = "${local.bastion_origin_sgs}"

  private_zone_name             = "${data.terraform_remote_state.vpc.private_zone_name}"
  private_zone_id               = "${data.terraform_remote_state.vpc.private_zone_id}"
  account_id                    = "${local.account_id}"
  tags                          = "${var.tags}"
  ssh_deployer_key              = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  subnet_ids                    = "${local.private_subnet_ids}"
  vpc_id                        = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr                      = "${data.terraform_remote_state.vpc.vpc_cidr_block}"
  s3-config-bucket              = "${var.remote_state_bucket_name}"
  bastion_inventory             =  "${var.bastion_inventory}"
  efs_file_system_id            = "${module.create_elasticseach_efs_backup_share.efs_id}"
  efs_mount_dir                 = "${local.backup_mount}"
  elasticsearch-backup-bucket   = "${module.create_backup_bucket.elastic_search_backup_bucket_name}"
  retention_period              = "${var.retention_period}"
  backup_retention_days         = "${var.backup_retention_days}"

}

module "create_monitoring_instance" {
  source = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//components/monitoring/monitoring-server"

  app_name                            = "mon-srv"
  amazon_ami_id                       = "${data.aws_ami.amazon_ami.id}"
  whitelist_monitoring_ips            = "${var.whitelist_monitoring_ips}"
  instance_type                       = "${local.instance_type}"
  ebs_device_volume_size              = "${local.ebs_device_volume_size}"
  docker_image_tag                    = "${local.docker_image_tag}"
  availability_zones                  = "${local.availability_zones}"
  short_environment_identifier        = "${var.short_environment_identifier}"
  environment_identifier              = "${var.environment_identifier}"
  region                              = "${var.region}"
  route53_sub_domain                  = "${local.route53_sub_domain}"
  route53_domain_private              = "${var.route53_domain_private}"
  route53_hosted_zone_id              = "${data.terraform_remote_state.vpc.public_zone_id}"
  public_ssl_arn                      = "${local.public_ssl_arn}"
  bastion_origin_cidr                 = "${data.terraform_remote_state.bastion_remote_vpc.bastion_vpc_cidr}"
  bastion_origin_sgs                  = "${local.bastion_origin_sgs}"

  private_zone_name                   = "${data.terraform_remote_state.vpc.private_zone_name}"
  private_zone_id                     = "${data.terraform_remote_state.vpc.private_zone_id}"
  account_id                          = "${local.account_id}"
  tags                                = "${var.tags}"
  ssh_deployer_key                    = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  subnet_ids                          = "${local.private_subnet_ids}"
  public_subnet_ids                   = "${local.public_subnet_ids}"
  vpc_id                              = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr                            = "${data.terraform_remote_state.vpc.vpc_cidr_block}"
  s3-config-bucket                    = "${var.remote_state_bucket_name}"
  elasticsearch_cluster_name          = "${module.create_elastic_cluster.elasticsearch_cluster_name}"
  elasticsearch_cluster_sg_client_id  = "${module.create_elastic_cluster.elasticsearch_cluster_sg_client_id}"
  bastion_inventory                   =  "${var.bastion_inventory}"
  efs_file_system_id                  = "${module.create_elasticseach_efs_backup_share.efs_id}"
  efs_mount_dir                       = "${local.backup_mount}"
  elasticsearch-backup-bucket         = "${module.create_backup_bucket.elastic_search_backup_bucket_name}"
  public_domain                       = "${var.subdomain}.${var.route53_domain_private}"
}

module "create_backup_bucket" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//components/monitoring/elasticsearch-backup-bucket"

  tags        = "${var.tags}"
  bucket_name = "${var.environment_type}-${var.project_name}-monitoring-backup-bucket"
  vpc_cidr    = "${data.terraform_remote_state.vpc.vpc_cidr_block}"
  account_id  = "${local.account_id}"
}
