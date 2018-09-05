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

# tags = {
#   owner                  = "Digital Studio"
#   environment-name       = "delius-core-dev"
#   application            = "delius-core"
#   is-production          = "false"
#   business-unit          = "hmpps"
#   infrastructure-support = "Digital Studio"
#   region                 = "eu-west-2"
#   provisioned-with       = "Terraform"
# }
