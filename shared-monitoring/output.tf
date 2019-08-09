# ECS
output "ecs_cluster_arn" {
  value = "${module.ecs_cluster.ecs_cluster_arn}"
}

output "ecs_cluster_id" {
  value = "${module.ecs_cluster.ecs_cluster_id}"
}

output "ecs_cluster_name" {
  value = "${module.ecs_cluster.ecs_cluster_name}"
}

output "loggroup_name" {
  value = {
    elasticsearch = "${module.create_loggroup.loggroup_name}"
    kibana        = "${module.kibana_loggroup.loggroup_name}"
    logstash      = "${module.logstash_loggroup.loggroup_name}"
    redis         = "${module.redis_loggroup.loggroup_name}"
  }
}

# ECS Service
output "ecs_service_id" {
  value = "${aws_ecs_service.elk_service.id}"
}

output "ecs_service_name" {
  value = "${aws_ecs_service.elk_service.name}"
}

output "monitoring_server_internal_url" {
  value = "${aws_route53_record.internal_monitoring_dns.fqdn}"
}

output "monitoring_server_external_url" {
  value = "${aws_route53_record.external_monitoring_dns.fqdn}"
}

output "monitoring_server_client_sg_id" {
  value = "${local.sg_monitoring_client}"
}

# EFS
output "monitoring_server_efs_share_arn" {
  value = "${module.efs_backups.efs_arn}"
}

output "monitoring_server_efs_share_id" {
  value = "${module.efs_backups.efs_id}"
}

output "monitoring_server_efs_share_dns" {
  value = "${module.efs_backups.efs_dns_name}"
}

# s3buckets

output "monitoring_server_bucket_name" {
  value = "${aws_s3_bucket.backups.id}"
}

output "monitoring_server_bucket_arn" {
  value = "${aws_s3_bucket.backups.arn}"
}

# IAM

output "iam_instance_profile" {
  value = "${module.create-iam-instance-profile-es.iam_instance_name}"
}

# Security groups
output "instance_security_groups" {
  value = "${local.instance_security_groups}"
}

# KMS Key
output "monitoring_kms_arn" {
  value = "${module.kms_key.kms_arn}"
}

# logstash
output "internal_logstash_host" {
  value = "${aws_route53_record.internal_logstash_dns.fqdn}"
}

output "external_logstash_host" {
  value = "${aws_route53_record.external_logstash_dns.fqdn}"
}
