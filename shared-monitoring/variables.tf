variable "region" {
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "short resource label or name"
}

variable "environment_type" {
}

variable "cloudwatch_log_retention" {
  default = "14"
}

variable "bastion_inventory" {
  default = "dev"
}

variable "environment_name" {
}

# Elasticsearch

variable "es_ecs_memory" {
  default = "9000"
}

variable "es_ecs_cpu_units" {
  default = "500"
}

variable "es_ecs_mem_limit" {
  default = "8500"
}

variable "es_image_url" {
  default = "mojdigitalstudio/hmpps-elasticsearch:latest"
}

variable "es_service_desired_count" {
  default = 4
}

variable "es_block_device" {
  default = "/dev/nvme1n1"
}

variable "es_instance_type" {
  default = "m5d.xlarge"
}

#LB
variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 60
}

variable "connection_draining" {
  description = "Boolean to enable connection draining"
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  default     = 300
}

variable "access_logs" {
  description = "An access logs block"
  type        = list(string)
  default     = []
}

# s3
variable "lb_account_id" {
}

variable "s3_lb_policy_file" {
  default = "./policies/s3_alb_policy.json"
}

# ecs
variable "es_jvm_heap_size" {
  default = "1g"
}

variable "es_master_nodes" {
  default = "2"
}

# SG
variable "sg_create_outbound_web_rules" {
  default = 1
}

variable "user_access_cidr_blocks" {
  type    = list(string)
  default = []
}

# kibana
variable "kibana_short_name" {
  default = ""
}

variable "elk_backups_config" {
  type = map(string)
  default = {
    transition_days                 = 7
    expiration_days                 = 14
    provisioned_throughput_in_mibps = 20
    throughput_mode                 = "provisioned"
  }
}

variable "ebs_optimized" {
  default = "false"
}

variable "volume_type" {
  default = "standard"
}

variable "elk_asg_props" {
  type = map(string)
  default = {
    min_size = 4
    max_size = 4
    desired  = 4
  }
}

