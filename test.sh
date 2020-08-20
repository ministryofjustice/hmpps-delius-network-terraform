#!/bin/bash
set -e
## HMPPS Inspec wrapper script.
## Run inspec tests for a given Terraform component/module.
##
## Example usage:
##    ENVIRONMENT=delius-test COMPONENT=vpc ./test.sh
##
##
## Environment variables are used to configure the script:
##  * ENVIRONMENT        Required. Which environment to run against, used to select Terraform
##                                 configuration from the config repository.
##  * CONFIG_LOCATION    Optional. Path to the environment configuration directory. Defaults
##                                 to ../hmpps-env-configs.
##  * COMPONENT          Optional. Sub-directory containing the Terraform code to apply.
##                                 Defaults to current directory.
##  * CONTAINER          Optional. The container to run the Terragrunt commands in. Defaults to
##                                 mojdigitalstudio/hmpps-terraform-builder-0-12.
##  * INSPEC_DIR         Optional. The directory containing the inspec tests. Defaults to
#                                  inspec_profiles.

# Print usage if ENVIRONMENT not set:
if [ "${ENVIRONMENT}" == "" ]; then grep '^##' "${0}" && exit; fi

# Print heading items. Note CodeBuild doesn't support color/formatting
heading() { [ -n "${CODEBUILD_CI}" ] && echo "${*}" || echo -e "\n\033[1m${*}\033[0m"; }

# Start container with mounted config:
if [ -z "${TF_IN_AUTOMATION}" ]; then

  if [ -z "${CONFIG_LOCATION}" ]; then
    heading No config provided. Using defaults...
    if [ "${ENVIRONMENT}" == "dev" ]; then CONFIG_LOCATION="$(pwd)/../hmpps-engineering-platform-terraform"
                                      else CONFIG_LOCATION="$(pwd)/../hmpps-env-configs"; fi
    if [ -d "${CONFIG_LOCATION}" ];   then echo "Mounting config from ${CONFIG_LOCATION}";
                                      else (echo "Couldn't find config at ${CONFIG_LOCATION}" && exit 1); fi
  fi

  heading Starting container...
  CONTAINER=${CONTAINER:-mojdigitalstudio/hmpps-terraform-builder-0-12}
  echo "${CONTAINER}"
  docker run \
    -e "COMPONENT=${COMPONENT}" \
    -e "ENVIRONMENT=${ENVIRONMENT}" \
    -e "CHEF_LICENSE=accept" \
    -e TF_IN_AUTOMATION=True \
    -v "${HOME}/.aws:/home/tools/.aws:ro" \
    -v "$(pwd):/home/tools/data" \
    -v "${CONFIG_LOCATION}:/home/tools/data/env_configs:ro" \
    -u root \
  "${CONTAINER}" bash -c "${0} ${*}"
  exit $?
fi

heading Checking workspace...
INSPEC_DIR="${INSPEC_DIR:-inspec_profiles}"
echo "${INSPEC_DIR}/${COMPONENT}"
if [ ! -d "${INSPEC_DIR}/${COMPONENT}" ]; then echo No tests found; exit 0; fi

heading Installing inspec...
# TODO move this installation into the docker image
gem install --no-document inspec inspec-bin
su - tools

heading Loading configuration...
test -f "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties" && source "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties"
test -f "env_configs/env_configs/${ENVIRONMENT}.properties" && source "env_configs/env_configs/${ENVIRONMENT}.properties"
export TERRAGRUNT_IAM_ROLE="${TERRAGRUNT_IAM_ROLE/admin/terraform}"
echo "Loaded $(env | grep -Ec '^(TF|TG)') properties"

heading Generating outputs...
cd "${COMPONENT}"
terragrunt output -json | tee "../${INSPEC_DIR}/${COMPONENT}/files/terraform.json"

heading Assuming IAM role...
CREDS=$(aws sts assume-role --role-arn "${TERRAGRUNT_IAM_ROLE}" --role-session-name "testing-${RANDOM}" --duration-seconds 900)
export AWS_ACCESS_KEY_ID=$(echo "${CREDS}" | jq .Credentials.AccessKeyId | xargs)
export AWS_SESSION_TOKEN=$(echo "${CREDS}" | jq .Credentials.SessionToken | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo "${CREDS}" | jq .Credentials.SecretAccessKey | xargs)

heading Running inspec...
inspec exec "../${INSPEC_DIR}/${COMPONENT}" -t "aws://${TG_REGION}"