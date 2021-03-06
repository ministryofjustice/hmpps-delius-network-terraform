module "create_elasticsearch_instance" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ec2_no_replace_instance?ref=terraform-0.12"
  app_name                    = var.app_name
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = var.user_data
  CreateSnapshot              = true
  tags                        = var.instance_tags
  key_name                    = var.ssh_deployer_key
  vpc_security_group_ids      = var.security_groups
  root_device_size            = "20"
}

module "create_elasticsearch_ebs_volume" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ebs/ebs_volume?ref=terraform-0.12"
  CreateSnapshot    = true
  tags              = var.volume_tags
  availability_zone = var.volume_availability_zone
  volume_size       = var.volume_size
  encrypted         = true
  app_name          = "${var.environment_identifier}-elasticsearch-volume"
}

module "attach_elasticsearch_1_ebs_volume" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/ebs/ebs_attachment?ref=terraform-0.12"
  device_name = "/dev/xvdb"
  instance_id = module.create_elasticsearch_instance.instance_id
  volume_id   = module.create_elasticsearch_ebs_volume.id
}

resource "aws_route53_record" "internal_elasticsearch_dns" {
  name    = "${var.hostname}-node${var.instance_id}.${var.zone_name}"
  type    = "A"
  zone_id = var.zone_id
  ttl     = 300
  records = [module.create_elasticsearch_instance.private_ip]
}

