# lambda-scheduler

Stop and start ec2, rds resources and autoscaling groups with lambda function.


## Features

*   Aws lambda runtine Python 3.7
*   ec2 instances scheduling
*   spot instances scheduling
*   rds clusters scheduling
*   rds instances scheduling
*   autoscalings scheduling
*   Aws CloudWatch logs for lambda

### Caveats
You can't stop and start an [Amazon Spot instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/how-spot-instances-work.html) (only the Spot service can stop and start a Spot Instance), but you can reboot or terminate a Spot Instance. That why this module support only scheduler action `terminate` for spot instance.

## Usage

```
module "stop_ec2_instance" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "ec2_stop"
  cloudwatch_schedule_expression = "cron(0 0 ? * FRI *)"
  schedule_action                = "stop"
  autoscaling_schedule           = "true"
  spot_schedule                  = "terminate"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  event_rule_enabled             = "false"
  resources_tag                  = {
    key   = "autostop-${var.environment_type}"
    value = "True"
  }
}

module "start_ec2_instance" {
  source                         = "modules/lambda-scheduler-stop-start/"
  name                           = "ec2_start"
  cloudwatch_schedule_expression = "cron(0 8 ? * MON *)"
  schedule_action                = "start"
  autoscaling_schedule           = "true"
  spot_schedule                  = "false"
  ec2_schedule                   = "true"
  rds_schedule                   = "false"
  event_rule_enabled             = "false"
  resources_tag                  = {
    key   = "autostop-${var.environment_type}"
    value = "True"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Define name to use for lambda function, cloudwatch event and iam role | string | n/a | yes |
| cloudwatch_schedule_expression | The scheduling expression | string | `"cron(0 22 ? * MON-FRI *)"` | yes |
| schedule_action | Define schedule action to apply on resources | string | `"stop/start"` | yes |
| resources_tag | Set the tag use to identify resources to stop or start | map | { autostop-${var.environment_type} = "True" } | yes |
| autoscaling_schedule | Enable scheduling on autoscaling resources | string | `"false"` | no |
| spot_schedule | Enable scheduling on spot instance resources | string | `"false"` | no |
| ec2_schedule | Enable scheduling on ec2 instance resources | string | `"false"` | no |
| rds_schedule | Enable scheduling on rds resources | string | `"false"` | no |
| event_rule_enabled | Whether event rule should be enabled | string | `"false"` | no |
