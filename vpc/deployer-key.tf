############################################
# DEPLOYER KEY FOR PROVISIONING
############################################

module "ssh_key" {
  source   = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssh_key"
  keyname  = "${var.environment_identifier}"
  rsa_bits = "4096"
}

# Add to SSM
module "create_parameter_ssh_key_private" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssm//parameter_store_file"
  parameter_name = "${var.environment_identifier}-ssh-private-key"
  description    = "${var.environment_identifier}-ssh-private-key"
  type           = "SecureString"
  value          = "${module.ssh_key.private_key_pem}"
  tags           = "${var.tags}"
}

module "create_parameter_ssh_key" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssm//parameter_store_file"
  parameter_name = "${var.environment_identifier}-ssh-public-key"
  description    = "${var.environment_identifier}-ssh-public-key"
  type           = "String"
  value          = "${module.ssh_key.public_key_openssh}"
  tags           = "${var.tags}"
}
