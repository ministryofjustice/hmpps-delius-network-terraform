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

variable "environment_identifier" {
  description = "resource label or name"
}

variable "route53_domain_private" {
  description = "Our private domain"
}

variable "short_environment_identifier" {
}

variable "project_name" {
}

variable "environment_type" {
}

variable "bastion_inventory" {
}

variable "ce_instances" {
  description = "List of permitted EC2 instance types to use for AWS Batch compute Environment"
  type        = list(string)
}

variable "ce_max_vcpu" {
  description = "Upper bound for active VCPUs in the AWS Batch Compute Environment. Must be >= VCPU count of largest instance type specified in dss_batch_instances"
}

variable "ce_min_vcpu" {
  description = "Lower bound for active VCPUs in the AWS Batch Compute Environment. 0 means env will be scaled down when not required"
}

variable "ce_queue_state" {
  description = "State of the Batch Queue: ENABLED or DISABLED"
}

variable "chaosmonkey_job_image" {
  description = "Chaosmonkey Docker Image"
}

variable "chaosmonkey_job_vcpus" {
  description = "No. of VCPUs to assign to the Chaosmonkey job"
}

variable "chaosmonkey_job_memory" {
  description = "Amount of RAM (GB) to assign to the Chaosmonkey job"
}

variable "chaosmonkey_job_retries" {
  description = "Number of retries for a failed Chaosmonkey job"
  default     = "1"
}

variable "chaosmonkey_job_envvars" {
  description = "List of aps of Environment Variables to pass to Chaosmonkey batch job"
  type        = list(object({
    name = string
    value = string
  }))
}

variable "chaosmonkey_job_ulimits" {
  description = "List of maps for ulimit values for Chaosmonkey batch job definition"
  type        = list(string)
}

