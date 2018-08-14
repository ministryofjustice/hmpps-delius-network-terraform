# hmpps-delius-network-terraform
Delius Network repo for creating VPC/subnets and shared things for environments.

This will create the base VPC, Subnets and Routes for any Delius environment.

## Environment configurations

The environment configurations live in the `env_configs` directory.

In here the convention is 

$project + _ + $environment_name

As you can see for one of the examples is the Sandpit environment for Delius Core named as

`delius-core_sandpit.tfvars` and `delius-core_sandpit.properties.sh`