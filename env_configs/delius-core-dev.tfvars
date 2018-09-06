route53_domain_private = "probation.hmpps.dsd.io"

aws_nameserver = "10.161.20.2"

vpc_supernet = "10.161.20.0/22"

public_subnet = "10.161.20.0/23"

private_subnet = "10.161.22.0/24"

db_subnet = "10.161.23.0/24"

availability_zone = {
  az1 = "eu-west-2a"
  az2 = "eu-west-2b"
  az3 = "eu-west-2c"
}

# ENVIRONMENT REMOTE STATES
eng_remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-dev-remote-state"
bastion_remote_state_bucket_name = "tf-eu-west-2-hmpps-bastion-dev-remote-state"

eng_role_arn = "arn:aws:iam::895523100917:role/terraform"
bastion_role_arn = "arn:aws:iam::895523100917:role/terraform"
