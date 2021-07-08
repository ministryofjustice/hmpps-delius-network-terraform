variable "environment_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "route53_domain_private" {
  description = "Our private domain"
}

variable "short_environment_name" {
}

variable "project_name" {
}

variable "bastion_inventory" {
}

variable "project_name_abbreviated" {
  description = "Shortened environment name"
}

variable "ecs_instance_type" {
  description = "EC2 instance type for ECS Hosts"
  default     = "m5.large"
}

variable "node_max_count" {
  description = "maximum ec2 instance count for shared ecs cluster"
  default     = 20
}

variable "node_min_count" {
  description = "minimum ec2 instance count for shared ecs cluster"
  default     = 1
}

variable "ecs_scale_up_cpu_threshold" {
  description = "Avg CPU reservation util above which to add more EC2 resource to the cluster within the boundaries set"
  default     = "50"
}

variable "ecs_scale_down_cpu_threshold" {
  description = "Avg CPU reservation util below which to remove EC2 resource to the cluster within the boundaries set"
  default     = "40"
}

variable "ecs_scale_up_mem_threshold" {
  description = "Avg Memory reservation util above which to add more EC2 resource to the cluster within the boundaries set"
  default     = "50"
}

variable "ecs_scale_down_mem_threshold" {
  description = "Avg Memory reservation util below which to remove EC2 resource to the cluster within the boundaries set"
  default     = "40"
}

variable "ecs_cluster_namespace_name" {
  description = "Private namespace domain name value"
  default     = "ecs.cluster"
}
