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

variable "oracle_observer_ecs_instance_type" {
  description = "EC2 instance type for Oracle Observer ECS Hosts"
  default     = "t3.micro"
}

variable "oracle_observer_cpu" {
   description = "CPU available to Oracle Observer Container"
   default     = 1024
}

variable "oracle_observer_memory" {
   description = "Memory (Mb) available to Oracle Observer Container"
   default     = 128
}

variable "database_high_availability_count" {
  description = "number of standby databases"
  type        = map(number)
}