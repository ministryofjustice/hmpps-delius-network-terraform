output "monitoring_server_internal_url" {
  value = "${module.create_monitoring_instance.monitoring_server_internal_dns}"
}

output "monitoring_server_internal_ipv4" {
  value = "${module.create_monitoring_instance.monitoring_server_internal_ipv4}"
}

output "monitoring_server_external_url" {
  value = "${module.create_monitoring_instance.monitoring_server_external_dns}"
}


output "monitoring_server_client_sg_id" {
  value = "${module.create_monitoring_instance.monitoring_server_client_security_group_id}"
}

output "monitoring_server_efs_share_arn" {
  value = "${module.create_elasticseach_efs_backup_share.efs_arn}"
}

output "monitoring_server_bucket_name" {
  value = "${module.create_backup_bucket.elastic_search_backup_bucket_name}"
}

output "monitoring_server_bucket_arn" {
  value = "${module.create_backup_bucket.elastic_search_backup_bucket_arn}"
}

output "monitoring_server_efs_share_id" {
  value = "${module.create_elasticseach_efs_backup_share.efs_id}"
}

output "elastic_cluster_node_1_internal_url" {
  value = "${module.create_elastic_cluster.elasticsearch_1_internal_dns}"
}

output "elastic_cluster_node_1_internal_ipv4" {
  value = "${module.create_elastic_cluster.elasticsearch_1_internal_ipv4}"
}

output "elastic_cluster_node_2_internal_url" {
  value = "${module.create_elastic_cluster.elasticsearch_2_internal_dns}"
}

output "elastic_cluster_node_2_internal_ipv4" {
  value = "${module.create_elastic_cluster.elasticsearch_2_internal_ipv4}"
}

output "elastic_cluster_node_3_internal_url" {
  value = "${module.create_elastic_cluster.elasticsearch_3_internal_dns}"
}

output "elastic_cluster_node_3_internal_ipv4" {
  value = "${module.create_elastic_cluster.elasticsearch_3_internal_ipv4}"
}