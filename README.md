# hmpps-delius-network-terraform
Delius Network repo for creating VPC/subnets and shared things for environments.

This will create the base VPC, Subnets and Routes for any Delius environment.

## Environment configurations

The environment configurations live in the `env_configs` directory.

In here the convention is 

$project + _ + $environment_name

As you can see for one of the examples is the Sandpit environment for Delius Core named as

`delius-core_sandpit.tfvars` and `delius-core_sandpit.properties.sh`

INSPEC
======

[Reference material](https://www.inspec.io/docs/reference/resources/#aws-resources)

## TERRAFORM TESTING

#### Temporary AWS creds 

Script __scripts/aws-get-temp-creds.sh__ has been written up to automate the process of generating the creds into a file __env_configs/inspec-creds.properties__

#### Usage

```
sh scripts/generate-terraform-outputs.sh
sh scripts/aws-get-temp-creds.sh
source env_configs/inspec-creds.properties
inspec exec ${inspec_profile} -t aws://${TG_REGION}
```

#### To remove the creds

```
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
export AWS_PROFILE=hmpps-token
source env_configs/dev.properties
rm -rf env_configs/inspec-creds.properties
```