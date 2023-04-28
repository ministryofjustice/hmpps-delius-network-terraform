# ECS Cluster ARN
output "oracle_observer_ecs_cluster_id" {
  value = aws_ecs_cluster.oracle_observer_ecs.arn
}

output "oracle_observer_ecs_cluster_name" {
  value = aws_ecs_cluster.oracle_observer_ecs.name
}

output "oracle_observer_ecs_cluster_efs_sg_id" {
  value = aws_security_group.oracle_observer_ecs_efs_sg.id
}