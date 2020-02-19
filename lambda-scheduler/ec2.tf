### Terraform modules ###

module "ec2-stop-pm" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "${var.environment_name}-stop-ec2"
  cloudwatch_schedule_expression = "${var.stop_cloudwatch_schedule_expression}"
  schedule_action                = "stop"
  spot_schedule                  = "false"
  ec2_schedule                   = "${var.ec2_schedule_stop_start}"
  rds_schedule                   = "false"
  autoscaling_schedule           = "false"

  resources_tag = {
    key   = "auto-stop"
    value = "true"
  }
}

module "ec2-start-am" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "${var.environment_name}-start-ec2"
  cloudwatch_schedule_expression = "${var.start_cloudwatch_schedule_expression}"
  schedule_action                = "start"
  spot_schedule                  = "false"
  ec2_schedule                   = "${var.ec2_schedule_stop_start}"
  rds_schedule                   = "false"
  autoscaling_schedule           = "false"

  resources_tag = {
    key   = "auto-stop"
    value = "true"
  }
}
