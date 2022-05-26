locals {

  route_table_for_endpoint_ids = [
    module.private_subnet_az1.routetableid,
    module.private_subnet_az2.routetableid,
    module.private_subnet_az3.routetableid,
    module.db_subnet_az1.routetableid,
    module.db_subnet_az2.routetableid,
    module.db_subnet_az3.routetableid
  ]

}

module "vpc" {
  source                 = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/vpc?ref=terraform-0.12"
  vpc_name               = var.environment_name
  vpc_dns_hosts          = var.aws_nameserver
  cidr_block             = var.vpc_supernet
  route53_domain_private = var.route53_domain_private
  tags                   = var.tags
}

resource "aws_vpc_endpoint" "s3-endpoint" {
  service_name      = "com.amazonaws.eu-west-2.s3"
  vpc_id            = module.vpc.vpc_id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.route_table_for_endpoint_ids
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_identifier}-${var.s3_gateway_endpoint_name}"
    },
  )
}
