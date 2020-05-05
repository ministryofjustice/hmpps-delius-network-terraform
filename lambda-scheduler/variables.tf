variable "environment_name" {}

variable "environment_type" {}

variable "region" {
  description = "The AWS region."
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

variable "stop_resources_tag_phase1" {
  description = "Autostop tag value used by lambda to stop instances"
  default     = "Phase1"
}

variable "stop_resources_tag_phase2" {
  description = "Autostop tag value used by lambda to stop instances"
  default     = "True"
}

variable "start_resources_tag_phase1" {
  description = "Autostop tag value used by lambda to start instances"
  default     = "Phase1"
}

variable "start_resources_tag_phase2" {
  description = "Autostop tag value used by lambda to start instances"
  default     = "True"
}

variable "calendar_rule_enabled" {
  description = "Whether the Calendar rule should be enabled"
  type        = "string"
  default     = "false"
}

variable "stop_cloudwatch_notification_schedule_expression" {
  description = "Notify an hour before stopping instance"
  default = "cron(00 18 ? * MON-FRI *)"
}

variable "tags" {
  type     = "map"
}

variable "rate_schedule_expression" {
  description = "Rate to check calendar events"
  default     = "cron(0/20 * * * ? *)"
}

variable "calender_content_doc" {
  description = "File for calendar ssm document"
  default     = "file://files/calendar_content"
}

variable "channel" {
  description = "Slack channel to send notification"
  default     = "delius_infra_ops"
}

variable "url_path" {
  description = "Slack url path"
  default     = "/services/T02DYEB3A/BS16X2JGY/r9e1CJYez7BDmwyliIl7WzLf"
}

variable "autostop_notify_rule_enabled" {
  description = "Whether the notification rule should be enabled"
  type        = "string"
  default     = "false"
}

variable "tagged_user" {
  description = "Users to be tagged in alerts"
  default = ""
}
