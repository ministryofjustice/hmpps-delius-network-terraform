# ECS Cluster ARN
output "shared_ecs_cluster_id" {
  value = aws_ecs_cluster.ecs.arn
}

output "shared_ecs_cluster_name" {
  value = aws_ecs_cluster.ecs.name
}

output "shared_ecs_cluster_efs_sg_id" {
  value = aws_security_group.ecs_efs_sg.id
}

output "private_cluster_namespace" {
  value = {
    id          = aws_service_discovery_private_dns_namespace.ecs_namespace.id
    domain_name = var.ecs_cluster_namespace_name
  }
}

