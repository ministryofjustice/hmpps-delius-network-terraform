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

variable "create_weblogic_capacity_provider" {
  description = "True if Weblogic ECS tasks hosted on own EC2 instances"
  type        = bool
  default     = false
}

variable "weblogic_ecs_instance_type" {
  description = "EC2 instance type for Weblogic ECS Hosts"
  default     = "m5.large"
}

variable "node_max_count" {
  description = "maximum ec2 instance count for shared ecs cluster"
  default     = 50
}

variable "node_min_count" {
  description = "minimum ec2 instance count for shared ecs cluster"
  default     = 1
}

variable "ecs_cluster_target_capacity" {
  description = "Target utilization for the capacity provider. A number between 1 and 100."
  default     = 75
}

variable "ecs_cluster_maximum_scaling_step_size" {
  description = "Maximum step adjustment size. A number between 1 and 10,000."
  default     = 10
}

variable "ecs_cluster_namespace_name" {
  description = "Private namespace domain name value"
  default     = "ecs.cluster"
}

variable "install_xdr_agent" {
  description = "Install XSIAM's XDR agent on ECS hosts"
  default     = false
}
