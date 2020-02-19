### Terraform modules ###

module "ec2-stop-pm" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "${var.environment_name}-stop-ec2"
  cloudwatch_schedule_expression = "${var.stop_cloudwatch_schedule_expression}"
  schedule_action                = "${var.ec2_schedule_stop_action}"
  spot_schedule                  = "false"
  ec2_schedule                   = "${var.ec2_enable_schedule}"
  rds_schedule                   = "${var.rds_schedule}"
  autoscaling_schedule           = "${var.autoscaling_schedule}"

  resources_tag = {
    key   = "auto-stop"
    value = "true"
  }
}

module "ec2-start-am" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "${var.environment_name}-start-ec2"
  cloudwatch_schedule_expression = "${var.start_cloudwatch_schedule_expression}"
  schedule_action                = "${var.ec2_schedule_start_action}"
  spot_schedule                  = "${var.spot_schedule}"
  ec2_schedule                   = "${var.ec2_enable_schedule}"
  rds_schedule                   = "${var.rds_schedule}"
  autoscaling_schedule           = "${var.autoscaling_schedule}"

  resources_tag = {
    key   = "auto-stop"
    value = "true"
  }
}
