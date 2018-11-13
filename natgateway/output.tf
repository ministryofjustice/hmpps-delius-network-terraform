output "natgateway_common-nat-id-az1" {
  value = "${module.common-nat-az1.natid}"
}

output "natgateway_common-nat-id-az2" {
  value = "${module.common-nat-az2.natid}"
}

output "natgateway_common-nat-id-az3" {
  value = "${module.common-nat-az3.natid}"
}

output "natgateway_common-nat-public-ip-az1" {
  value = "${module.common-nat-az1.nat_public_ip}"
}

output "natgateway_common-nat-public-ip-az2" {
  value = "${module.common-nat-az2.nat_public_ip}"
}

output "natgateway_common-nat-public-ip-az3" {
  value = "${module.common-nat-az3.nat_public_ip}"
}

output "natgateway_common-nat-private-ip-az1" {
  value = "${module.common-nat-az1.nat_private_ip}"
}

output "natgateway_common-nat-private-ip-az2" {
  value = "${module.common-nat-az2.nat_private_ip}"
}

output "natgateway_common-nat-private-ip-az3" {
  value = "${module.common-nat-az3.nat_private_ip}"
}
