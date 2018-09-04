vpc_supernet = "10.161.20.0/22"

public_subnet = "10.161.20.0/23"

public-cidr = {
  az1 = "10.161.75.0/27"

  az2 = "10.161.75.32/27"

  az3 = "10.161.75.64/27"
}

private_subnet = "10.161.22.0/24"

db_subnet = "10.161.23.0/24"

availability_zone = {
  az1 = "eu-west-2a"

  az2 = "eu-west-2b"

  az3 = "eu-west-2c"
}

tags = {
  owner                  = "Digital Studio"
  environment-name       = "delius-core-dev"
  application            = "delius-core"
  is-production          = "false"
  business-unit          = "hmpps"
  infrastructure-support = "Digital Studio"
  region                 = "eu-west-2"
  provisioned-with       = "Terraform"
}
