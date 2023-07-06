resource "openstack_compute_instance_v2" "exec-node" {
  count           = var.exec_node_count
  name            = "${var.name_prefix}exec-node-${count.index}"
  flavor_name     = var.flavors.exec-node
  image_id        = data.openstack_images_image_v2.htcondor-image.id
  key_pair        = data.openstack_compute_keypair_v2.cloud-key.name
  security_groups = var.secgroups
  # depends_on      = [openstack_compute_instance_v2.nfs-server]

  network {
    uuid = data.openstack_networking_network_v2.internal.id
  }

  user_data = data.template_file.exec_node_user_data.rendered
}
