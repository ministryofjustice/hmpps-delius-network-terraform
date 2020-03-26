variable "environment_name" {}

variable "environment_type" {}

variable "region" {
  description = "The AWS region."
}

variable "start_cloudwatch_schedule_expression" {
  description = "The time to start instances"
  default = "cron(0 05 ? * MON-FRI *)"
}

variable "stop_cloudwatch_schedule_expression" {
  description = "The time to stop instances"
  default = "cron(0 19 ? * MON-FRI *)"
}

variable "schedule_start_action" {
  description = "Define the schedule option - ie start or stop"
  default     = "start"
}

variable "schedule_stop_action" {
  description = "Define the schedule option - ie start or stop"
  default     = "stop"
}

variable "ec2_schedule" {
  description = "Enable or disable the auto start and power off of instances"
  default     = "false"
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

variable "stop_resources_tag" {
description = "Autostop tag value used by lambda to stop instances"
default     = "True"
}

variable "start_resources_tag" {
description = "Autostop tag value used by lambda to start instances"
default     = "True"
}

variable "auto_stop_rule_enabled" {
  description = "Whether the rule should be enabled"
  type        = "string"
  default     = "false"
}

variable "auto_start_rule_enabled" {
  description = "Whether the rule should be enabled"
  type        = "string"
  default     = "false"
}

variable "calendar_rule_enabled" {
  description = "Whether the Calendar rule should be enabled"
  type        = "string"
  default     = "false"
}


variable "stop_cloudwatch_notification_schedule_expression" {
  description = "Notify an hour before stopping instance"
  default = "cron(00 19 ? * MON-FRI *)"
}

variable "tags" {
  type     = "map"
}

variable "rate_schedule_expression" {
  description = "Rate to check calendar events"
  default     = "rate(15 minutes)"
}

variable "calender_content_doc" {
  description = "File for calendar ssm document"
  default     = "file://files/calendar_content"
}
