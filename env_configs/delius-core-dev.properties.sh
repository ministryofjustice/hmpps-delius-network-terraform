#!/usr/bin/env bash

# AWS ROLE ARN
# AWS subaccount 723123699647 delius-core-non-prod
export TERRAGRUNT_IAM_ROLE="arn:aws:iam::723123699647:role/terraform"

## GENERIC VARIABLES

# AWS-REGION
export TG_REGION="eu-west-2"

# BUSINESS_UNIT
export TG_BUSINESS_UNIT="hmpps"

# PROJECT
export TG_PROJECT_NAME="delius-core"

# ENVIRONMENT
export TG_ENVIRONMENT_TYPE="dev"

export IS_PRODUCTION="false"
export OWNER="Digital Studio"
export INFRASTRUCTURE_SUPPORT="Digital Studio"

## TERRAGUNT VARIABLES

export TG_ENVIRONMENT_IDENTIFIER="tf-${TG_REGION}-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}"
export TG_SHORT_ENVIRONMENT_IDENTIFIER="tf-${TG_BUSINESS_UNIT}-${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}"
export TG_ENVIRONMENT_NAME="${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}"

# REMOTE_STATE_BUCKET
export TG_REMOTE_STATE_BUCKET="${TG_ENVIRONMENT_IDENTIFIER}-remote-state"

# ###################
# TERRAFORM VARIABLES
# ###################

export TF_VAR_role_arn=${TERRAGRUNT_IAM_ROLE}
export TF_VAR_region=${TG_REGION}
export TF_VAR_business_unit=${TG_BUSINESS_UNIT}
export TF_VAR_project_name=${TG_PROJECT_NAME}
export TF_VAR_environment_type=${TG_ENVIRONMENT_TYPE}
export TF_VAR_owner=${OWNER}

# export TF_VAR_project=${TG_PROJECT}
# export TF_VAR_environment=${TG_ENVIRONMENT}
export TF_VAR_is_production=${IS_PRODUCTION}
export TF_VAR_environment_identifier=${TG_ENVIRONMENT_IDENTIFIER}
export TF_VAR_short_environment_identifier=${TG_SHORT_ENVIRONMENT_IDENTIFIER}
export TF_VAR_environment_name=${TG_ENVIRONMENT_NAME}
export TF_VAR_remote_state_bucket_name=${TG_REMOTE_STATE_BUCKET}

# Standard tags
export TF_VAR_tags="{ \
owner = \"${OWNER}\", \
environment-name = \"${TG_PROJECT_NAME}-${TG_ENVIRONMENT_TYPE}\", \
environment = \"${TG_ENVIRONMENT_TYPE}\", \
application = \"${TG_PROJECT_NAME}\", \
is-production = \"${IS_PRODUCTION}\", \
business-unit = \"${TG_BUSINESS_UNIT}\", \
infrastructure-support = \"${INFRASTRUCTURE_SUPPORT}\", \
region = \"${TG_REGION}\", \
provisioned-with  = \"Terraform\" \
}"

# Inspec testing
export attributes_dir="$(pwd)/attributes"

export attributes_file="${attributes_dir}/${TG_ENVIRONMENT_IDENTIFIER}.yml"

export inspec_profile="inspec_profiles/aws-inspec-profile"

export attributes_list="vpc"