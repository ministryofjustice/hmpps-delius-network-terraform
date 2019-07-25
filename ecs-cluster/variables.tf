variable "environment_name" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "route53_domain_private" {
  description = "Our private domain"
}

variable "short_environment_identifier" {}

variable "project_name" {}

variable "environment_type" {}

variable "bastion_inventory" {}

variable "project_name_abbreviated" {
  description = "Shortened environment name"
}

# Note that to use cloudsto volume plugin, nitro based ECS instances can't be used atm
# This means cannot use t3, m5, c5 or r5 instance types until plugin supports new volume names used on nitro instances
variable "ecs_instance_type" {
  description = "EC2 instance type for ECS Hosts"
  default     = "t2.medium"
}

variable "node_max_count" {
  description = "maximum ec2 instance count for shared ecs cluster"
  default     = 5
}

variable "node_min_count" {
  description = "minimum ec2 instance count for shared ecs cluster"
  default     = 1
}

variable "ecs_scale_up_cpu_threshold" {
  description = "Avg CPU Util above which to add more EC2 resource to the cluster within the boundaries set"
  default     = "70"
}

variable "ecs_scale_down_cpu_threshold" {
  description = "Avg CPU Util below which to add more EC2 resource to the cluster within the boundaries set"
  default     = "40"
}

variable "ecs_cluster_namespace_name" {
  description = "Private namespace domain name value"
  default     = "ecs.cluster"
}

variable "cloudstor_plugin_version" {
  description = "Docker cloudstor ebs volume plugin version"
  default     = "docker4x/cloudstor:18.09.2-ce-aws1"
}
