locals {
    project_name = var.project_name == "delius-core" ? var.short_environment_name : var.project_name

    cloudtrail_bucket = "${var.environment_identifier}-cloudtrail-s3bucket"
    xsiam_bucket      = "${var.environment_identifier}-xsiam-agent-s3bucket"
    aws_config_bucket = "${var.environment_identifier}-config-service-s3bucket"
    
    vpc_log_format = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${packets} $${log-status} $${pkt-srcaddr} $${pkt-dstaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${type} $${vpc-id} $${version}"
}