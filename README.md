# hmpps-delius-network-terraform
Delius Network repo for creating VPC/subnets and shared things for environments.

This will create the base VPC, Subnets and Routes for any Delius environment.

## Environment configurations

The environment configurations live in the `env_configs` directory.

In here the convention is

$project + _ + $environment_name

As you can see for one of the examples is the Sandpit environment for Delius Core named as

`delius-core_sandpit.tfvars` and `delius-core_sandpit.properties.sh`

## Network

The subnets are not allocated linearly. The private subnets have much more addresses than the public and database subnets.

The allocation is as per this example for a /20 mask

```
10.162.0.0/20

private az1 10.162.0.0/22
private az2 10.162.4.0/22
private az3 10.162.8.0/22

db az1 10.162.12.0/24
db az2 10.162.13.0/24
db az3 10.162.14.0/25

public az1 10.162.14.128/25
public az2 10.162.15.0/25
public az3 10.162.15.128/25
```

| Subnet address |	Netmask	| Range of addresses |	Useable IPs	| Hosts	|
|---|---|---|---|---|
|10.162.0.0/22 |	255.255.252.0	| 10.162.0.0 - 10.162.3.255	| 10.162.0.1 - 10.162.3.254 |	1022 |
|10.162.4.0/22 |	255.255.252.0 |	10.162.4.0 - 10.162.7.255	| 10.162.4.1 - 10.162.7.254 |	1022 |
|10.162.8.0/22 |	255.255.252.0	| 10.162.8.0 - 10.162.11.255 | 10.162.8.1 - 10.162.11.254 |	1022 |
|10.162.12.0/24 |	255.255.255.0	| 10.162.12.0 - 10.162.12.255	| 10.162.12.1 - 10.162.12.254	| 254 |
|10.162.13.0/24 |	255.255.255.0	| 10.162.13.0 - 10.162.13.255	| 10.162.13.1 - 10.162.13.254	| 254 |
|10.162.14.0/25 |	255.255.255.128	| 10.162.14.0 - 10.162.14.127	| 10.162.14.1 - 10.162.14.126	| 126	|
|10.162.14.128/25 |	255.255.255.128	| 10.162.14.128 - 10.162.14.255	| 10.162.14.129 - 10.162.14.254 |	126 |
|10.162.15.0/25 |	255.255.255.128	| 10.162.15.0 - 10.162.15.127	| 10.162.15.1 - 10.162.15.126 |	126 |
|10.162.15.128/25 |	255.255.255.128	| 10.162.15.128 - 10.162.15.255	| 10.162.15.129 - 10.162.15.254 |	126 |

The proportions are same for smaller cidr range, however a mask smaller than /24 is not recommended.


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
