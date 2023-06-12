locals {
  # Handle mixed environments project name. This accounts for naming conflicts related to Dev/Sandpit environments running in the same account.
  project_name = var.project_name == "delius-core" ? var.short_environment_name : var.project_name
  name_prefix  = "${var.project_name_abbreviated}-${local.project_name}"

  oracle_observer_ecs_cluster_name = "${local.name_prefix}-oracle-observer-ecscluster-private-ecs"

  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]

  db_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az3,
  ]

  sys_password_path = "/${var.environment_name}/${var.project_name}/delius-database/db/oradb_sys_password"

  oradb_sys_password_parameter = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${local.sys_password_path}"
}