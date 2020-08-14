output "elasticsearch2_cluster_sg_client_id" {
  value = module.create_elastic2_cluster.elasticsearch_cluster_sg_client_id
}

output "elasticsearch2_1_internal_dns" {
  value = module.create_elastic2_cluster.elasticsearch_1_internal_dns
}

output "elasticsearch2_1_internal_ipv4" {
  value = module.create_elastic2_cluster.elasticsearch_1_internal_ipv4
}

output "elasticsearch2_2_internal_dns" {
  value = module.create_elastic2_cluster.elasticsearch_2_internal_dns
}

output "elasticsearch2_2_internal_ipv4" {
  value = module.create_elastic2_cluster.elasticsearch_2_internal_ipv4
}

output "elasticsearch2_3_internal_dns" {
  value = module.create_elastic2_cluster.elasticsearch_3_internal_dns
}

output "elasticsearch2_3_internal_ipv4" {
  value = module.create_elastic2_cluster.elasticsearch_3_internal_ipv4
}

output "elasticsearch2_cluster_name" {
  value = module.create_elastic2_cluster.elasticsearch_cluster_name
}

output "elasticsearch2_efs_dns" {
  value = module.create_elastic2_efs_backup_share.efs_dns_name
}

output "elasticsearch2_efs_cname" {
  value = module.create_elastic2_efs_backup_share.dns_cname
}

output "staging_bucket_name" {
  value = aws_s3_bucket.elasticsearch_backup_bucket.bucket
}

