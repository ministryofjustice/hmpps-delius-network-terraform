output "natgateway_common-nat-id-az1" {
  value = "${module.common-nat-az1.natid}"
}

output "natgateway_common-nat-id-az2" {
  value = "${module.common-nat-az2.natid}"
}

output "natgateway_common-nat-id-az3" {
  value = "${module.common-nat-az3.natid}"
}
