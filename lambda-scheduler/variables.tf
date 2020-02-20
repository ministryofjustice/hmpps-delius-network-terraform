variable "environment_name" {}

variable "region" {
  description = "The AWS region."
}

variable "start_cloudwatch_schedule_expression" {
  description = "The time to start instances"
}

variable "stop_cloudwatch_schedule_expression" {
  description = "The time to stop instances"
}

variable "ec2_schedule" {
  description = "Enable or disable the auto start and power off of instances"
  default     = "false"
}

variable "schedule_start_action" {
  description = "Define the schedule option - ie start or stop"
  default     = "start"
}

variable "schedule_stop_action" {
  description = "Define the schedule option - ie start or stop"
  default     = "stop"
}

variable "spot_schedule" {
  description = "Enable or disable auto start/stop of spot instances"
  default     = "false"
}

variable "rds_schedule" {
  description = "Enable or disable auto start/stop of RDS Instances"
  default     = "false"
}

variable "autoscaling_schedule" {
  description = "Enable or disable auto start/stop of ASG"
  default     = "false"
}
