terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11"
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

locals {
  environment_name = "${var.project_name}-${var.environment_type}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${local.environment_name}"
  }
}

data "aws_vpc_peering_connection" "bastion_peering" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Name = "${local.environment_name}-to-bastion-vpc"
  }
}

data "aws_internet_gateway" "igw" {
  tags {
    Name = "${local.environment_name}-igw"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Type = "public"
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Type = "private"
  }
}

data "aws_subnet_ids" "db_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Type = "db"
  }
}
