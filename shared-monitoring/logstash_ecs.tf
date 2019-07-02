locals {
  logstash_containerports = {
    http = 9600
    logs = 2514
  }
}

############################################
# CREATE LB FOR INGRESS NODE
############################################

# elb

resource "aws_elb" "mon_lb" {
  name            = "${local.common_name}-mon"
  subnets         = ["${local.private_subnet_ids}"]
  security_groups = ["${local.lb_security_groups}"]
  internal        = true

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  listener {
    instance_port     = "${local.logstash_containerports["logs"]}"
    instance_protocol = "tcp"
    lb_port           = "${local.logstash_containerports["logs"]}"
    lb_protocol       = "tcp"
  }

  access_logs = {
    bucket        = "${module.s3_lb_logs_bucket.s3_bucket_name}"
    bucket_prefix = "${local.common_name}-mon"
    interval      = 60
  }

  health_check = [
    {
      target              = "TCP:${local.logstash_containerports["logs"]}"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]

  tags = "${merge(local.tags, map("Name", format("%s", "${local.common_name}-mon")))}"
}

############################################
# CREATE LOG GROUPS FOR CONTAINER LOGS
############################################

module "logstash_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${local.common_name}"
  loggroupname             = "logstash"
  cloudwatch_log_retention = "${var.cloudwatch_log_retention}"
  tags                     = "${local.tags}"
}

module "redis_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${local.common_name}"
  loggroupname             = "redis"
  cloudwatch_log_retention = "${var.cloudwatch_log_retention}"
  tags                     = "${local.tags}"
}

############################################
# CREATE ECS TASK DEFINTIONS
############################################

data "aws_ecs_task_definition" "logstash" {
  task_definition = "${aws_ecs_task_definition.logstash.family}"
  depends_on      = ["aws_ecs_task_definition.logstash"]
}

data "template_file" "logstash" {
  template = "${file("./task_definitions/logstash.conf")}"

  vars {
    logstash_loggroup = "${module.logstash_loggroup.loggroup_name}"
    redis_loggroup    = "${module.redis_loggroup.loggroup_name}"
    log_group_region  = "${local.region}"
    registry_url      = "${local.registry_url}"
    docker_tag        = "${local.docker_tag}"
    es_host_url       = "${aws_route53_record.internal_monitoring_dns.fqdn}:${local.port}"
  }
}

resource "aws_ecs_task_definition" "logstash" {
  family                = "${local.common_name}-${local.service_type}"
  container_definitions = "${data.template_file.logstash.rendered}"

  volume {
    name      = "confd"
    host_path = "${local.es_home_dir}/conf.d/logstash.conf.tmpl"
  }
}

############################################
# CREATE ECS SERVICES
############################################

module "mon_service" {
  source                          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecs/ecs_service//withloadbalancer//elb"
  servicename                     = "${local.common_name}-${local.service_type}"
  clustername                     = "${module.ecs_cluster.ecs_cluster_id}"
  ecs_service_role                = "${module.create-iam-ecs-role-int.iamrole_arn}"
  task_definition_family          = "${aws_ecs_task_definition.logstash.family}"
  task_definition_revision        = "${aws_ecs_task_definition.logstash.revision}"
  current_task_definition_version = "${data.aws_ecs_task_definition.logstash.revision}"
  service_desired_count           = "2"
  elb_name                        = "${aws_elb.mon_lb.name}"
  containername                   = "${local.service_type}"
  containerport                   = "${local.logstash_containerports["logs"]}"
}
