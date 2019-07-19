# ECS Cluster ARN
output "shared_ecs_cluster_id" {
    value = "${aws_ecs_cluster.ecs.arn}"
}

output "private_cluster_namespace" {
    value = "${aws_service_discovery_private_dns_namespace.ecs_namespace.id}"
}