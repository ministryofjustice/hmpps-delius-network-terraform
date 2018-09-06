vpc_supernet = "10.161.4.0/23"

public_subnet = "10.161.4.0/24"

private_subnet = "10.161.4.128/25"

db_subnet = "10.161.5.0/25"

tags = {
  owner                  = "Digital Studio"
  environment-name       = "delius-core-sandpit"
  application            = "delius-core"
  is-production          = "false"
  business-unit          = "hmpps"
  infrastructure-support = "Digital Studio"
  region                 = "eu-west-2"
  provisioned-with       = "Terraform"
}

# ENVIRONMENT REMOTE STATES
eng_remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-dev-remote-state"
bastion_remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-dev-remote-state"
