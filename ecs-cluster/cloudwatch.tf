resource "aws_cloudwatch_metric_alarm" "ecs_host_root_vol_capacity_warning" {
  alarm_name                = "${aws_ecs_cluster.ecs.name}-container-instance-root-volume-capacity--warning"
  alarm_description         = "The root volume of one or more delius-core ecs container instances is over 80% full. Check cloudwatch metrics for more details and take appropriate action."
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  threshold                 = 70
  alarm_actions             = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions                = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  treat_missing_data        = "ignore"

  metric_query {
    id          = "q1"
    expression  = "SELECT MAX(disk_used_percent) FROM SCHEMA(CWAgent, AutoScalingGroupName,InstanceId,device,fstype,path) WHERE AutoScalingGroupName = '${aws_autoscaling_group.ecs_asg.name}'"
    label       = "highest_ecs_container_instance_root_vol_usage_percentage"
    return_data = "true"
    period      = 300
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_host_root_vol_capacity_critical" {
  alarm_name                = "${aws_ecs_cluster.ecs.name}-container-instance-root-volume-capacity--critical"
  alarm_description         = "The root volume of one or more delius-core ecs container instances is over 90% full. Check cloudwatch metrics for more details and take appropriate action."
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  threshold                 = 80
  alarm_actions             = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions                = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  treat_missing_data        = "ignore"

  metric_query {
    id          = "q1"
    expression  = "SELECT MAX(disk_used_percent) FROM SCHEMA(CWAgent, AutoScalingGroupName,InstanceId,device,fstype,path) WHERE AutoScalingGroupName = '${aws_autoscaling_group.ecs_asg.name}'"
    label       = "highest_ecs_container_instance_root_vol_usage_percentage"
    return_data = "true"
    period      = 300
  }

  tags = var.tags
}
