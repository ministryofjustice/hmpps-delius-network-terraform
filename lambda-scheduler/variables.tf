variable "environment_name" {}

variable "region" {
  description = "The AWS region."
}

variable "start_cloudwatch_schedule_expression" {}

variable "stop_cloudwatch_schedule_expression" {}

variable "ec2_schedule_stop_start" {}
