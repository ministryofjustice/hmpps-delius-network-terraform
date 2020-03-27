### Terraform modules ###


################################################
#
#            EC2 Instances
#
################################################
module "ec2-stop-pm" {
  source                         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//auto-start//lambda-scheduler-stop-start"
  name                           = "${var.environment_name}-stop-ec2"
  cloudwatch_schedule_expression = "${var.stop_cloudwatch_schedule_expression}"
  schedule_action                = "${var.schedule_stop_action}"
  spot_schedule                  = "${var.spot_schedule}"
  ec2_schedule                   = "${var.ec2_schedule}"
  rds_schedule                   = "${var.rds_schedule}"
  autoscaling_schedule           = "${var.autoscaling_schedule}"
  event_rule_enabled             = "${var.auto_stop_rule_enabled}"

  resources_tag = {
    key   = "autostop-${var.environment_type}"
    value = "${var.stop_resources_tag}"
  }
}

module "ec2-start-am" {
  source                         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//auto-start//lambda-scheduler-stop-start"
  name                           = "${var.environment_name}-start-ec2"
  cloudwatch_schedule_expression = "${var.start_cloudwatch_schedule_expression}"
  schedule_action                = "${var.schedule_start_action}"
  spot_schedule                  = "${var.spot_schedule}"
  ec2_schedule                   = "${var.ec2_schedule}"
  rds_schedule                   = "${var.rds_schedule}"
  autoscaling_schedule           = "${var.autoscaling_schedule}"
  event_rule_enabled             = "${var.auto_start_rule_enabled}"

  resources_tag = {
    key   = "autostop-${var.environment_type}"
    value = "${var.start_resources_tag}"
  }
}

module "autostop-notify" {
  source                         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//auto-start//auto-stop-notify"
  name                           = "${var.environment_name}"
  cloudwatch_schedule_expression = "${var.stop_cloudwatch_notification_schedule_expression}"
  event_rule_enabled             = "${var.calendar_rule_enabled}"
}

module "calendar" {
  source                         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//auto-start//calendar"
  environment_name               = "${var.environment_name}"
  tags                           = "${var.tags}"
  region                         = "${var.region}"
  is_enabled                     = "${var.calendar_rule_enabled}"
  schedule_expression            = "${var.rate_schedule_expression}"
  calender_content_doc           = "${var.calender_content_doc}"
}
