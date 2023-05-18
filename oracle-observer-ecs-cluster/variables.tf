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
  default     = "t3.nano"
}