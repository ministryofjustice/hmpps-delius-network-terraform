#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the shared oracle-db-operation security groups
#-------------------------------------------------------------
data "terraform_remote_state" "ora_db_op_security_groups" {
  backend = "s3"

  config = {
    bucket   = var.oracle_db_operation["eng_remote_state_bucket_name"]
    key      = "oracle-db-operation/security-groups/terraform.tfstate"
    region   = var.region
    role_arn = var.oracle_db_operation["eng_role_arn"]
  }
}
