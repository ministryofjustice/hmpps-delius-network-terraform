locals {
  kibana_port           = 5601
  kibana_protocol       = "HTTP"
  kibana_container_name = "kibana"
  target_grp_name       = "${var.kibana_short_name != "" ? var.kibana_short_name : local.kibana_container_name}"
}

# target group
module "kibana_target_grp" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb/targetgroup"
  appname             = "${local.common_name}-${local.target_grp_name}"
  target_port         = "${local.kibana_port}"
  target_protocol     = "${local.kibana_protocol}"
  vpc_id              = "${local.vpc_id}"
  target_type         = "instance"
  tags                = "${local.tags}"
  check_interval      = "30"
  check_path          = "/api/status"
  check_port          = "${local.kibana_port}"
  check_protocol      = "${local.kibana_protocol}"
  timeout             = 5
  healthy_threshold   = 3
  unhealthy_threshold = 3
  return_code         = "200-299"
}

# listener
module "kibana_alb_listener" {
  source           = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb/create_listener_with_https"
  lb_arn           = "${module.create_app_alb.lb_arn}"
  lb_port          = 443
  lb_protocol      = "HTTPS"
  target_group_arn = "${module.kibana_target_grp.target_group_arn}"
  certificate_arn  = ["${local.certificate_arn}"]
}

############################################
# CREATE LOG GROUPS FOR CONTAINER LOGS
############################################

module "kibana_loggroup" {
  source                   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//loggroup"
  log_group_path           = "${local.common_name}"
  loggroupname             = "${local.kibana_container_name}"
  cloudwatch_log_retention = "${var.cloudwatch_log_retention}"
  tags                     = "${local.tags}"
}

############################################
# CREATE ECS TASK DEFINTIONS
############################################

data "aws_ecs_task_definition" "kibana" {
  task_definition = "${aws_ecs_task_definition.kibana.family}"
  depends_on      = ["aws_ecs_task_definition.kibana"]
}

data "template_file" "kibana" {
  template = "${file("./task_definitions/kibana.conf")}"

  vars {
    registry_url     = "${local.registry_url}"
    docker_tag       = "${local.docker_tag}"
    container_name   = "${local.kibana_container_name}"
    log_group_region = "${local.region}"
    kibana_loggroup  = "${module.kibana_loggroup.loggroup_name}"
    es_host_url      = "${aws_route53_record.internal_monitoring_dns.fqdn}"
    server_name      = "${local.common_name}-${local.kibana_container_name}"
  }
}

resource "aws_ecs_task_definition" "kibana" {
  family                = "${local.kibana_container_name}-task-definition"
  container_definitions = "${data.template_file.kibana.rendered}"
}

module "kibana_service" {
  source                          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ecs/ecs_service//withloadbalancer//alb"
  servicename                     = "${local.common_name}-${local.kibana_container_name}"
  clustername                     = "${module.ecs_cluster.ecs_cluster_id}"
  ecs_service_role                = "${module.create-iam-ecs-role-int.iamrole_arn}"
  task_definition_family          = "${aws_ecs_task_definition.kibana.family}"
  task_definition_revision        = "${aws_ecs_task_definition.kibana.revision}"
  current_task_definition_version = "${data.aws_ecs_task_definition.kibana.revision}"
  service_desired_count           = "2"
  target_group_arn                = "${module.kibana_target_grp.target_group_arn}"
  containername                   = "${local.kibana_container_name}"
  containerport                   = "${local.kibana_port}"
}
