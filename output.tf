output "CM_node_name" {
  value = openstack_compute_instance_v2.central-manager.name
}

output "CM_internal_IP" {
  value = openstack_compute_instance_v2.central-manager.access_ip_v4
}

output "CM_public_IP" {
  value = openstack_networking_floatingip_v2.pub_ip.address
}

output "exec_nodes_IPs" {
  value = {
    for instance in openstack_compute_instance_v2.exec-node : instance.name => instance.access_ip_v4
  }
}

output "nfs_server_IP" {
  value = openstack_compute_instance_v2.nfs-server.access_ip_v4
}
