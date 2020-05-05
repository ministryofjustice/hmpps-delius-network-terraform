# ############################################
# # CREATE AUTO SCALING GROUP
# ############################################
resource "aws_launch_configuration" "environment" {
  name_prefix                 = "${local.common_name}-es-"
  image_id                    = "${data.aws_ami.ecs_ami.id}"
  instance_type               = "${var.es_instance_type}"
  iam_instance_profile        = "${module.create-iam-instance-profile-es.iam_instance_name}"
  key_name                    = "${local.ssh_deployer_key}"
  security_groups             = ["${local.instance_security_groups}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.userdata_ecs.rendered}"
  enable_monitoring           = true
  ebs_optimized               = "${var.ebs_optimized}"

  root_block_device {
    volume_type = "${var.volume_type}"
    volume_size = 60
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  ecs_tags = "${merge(data.terraform_remote_state.vpc.tags, map("es_cluster_discovery", "${local.common_name}"))}"
}

data "null_data_source" "tags" {
  count = "${length(keys(local.ecs_tags))}"

  inputs = {
    key                 = "${element(keys(local.ecs_tags), count.index)}"
    value               = "${element(values(local.ecs_tags), count.index)}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "environment" {
  name                 = "${local.common_name}-all"
  vpc_zone_identifier  = ["${local.private_subnet_ids}"]
  min_size             = "${var.elk_asg_props["min_size"]}"
  max_size             = "${var.elk_asg_props["max_size"]}"
  desired_capacity     = "${var.elk_asg_props["desired"]}"
  launch_configuration = "${aws_launch_configuration.environment.name}"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${local.common_name}-all"
      propagate_at_launch = true
    },
  ]
}
