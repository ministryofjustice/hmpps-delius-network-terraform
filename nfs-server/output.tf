output "nfs_client_sg_id" {
  value = "${module.nfs-server.nfs_client_sg_id}"
}

output "nfs_host_fqdn" {
  value = "${module.nfs-server.nfs_host_fqdn}"
}

output "nfs_host_private_dns" {
  value = "${module.nfs-server.nfs_host_private_dns}"
}

output "nfs_host_private_ip" {
  value = "${module.nfs-server.nfs_host_private_ip}"
}
