resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "${var.name_prefix}nfs"
  image_id        = data.openstack_images_image_v2.htcondor-image.id
  flavor_name     = var.flavors.nfs-server
  key_pair        = data.openstack_compute_keypair_v2.cloud-key.name
  security_groups = var.secgroups

  network {
    uuid = data.openstack_networking_network_v2.internal.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.htcondor-image.id
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume_nfs_data.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = -1
    delete_on_termination = true
  }

  user_data = data.cloudinit_config.nfs-share.rendered
}

resource "openstack_blockstorage_volume_v3" "volume_nfs_data" {
  name        = "${var.nfs.name}_volume"
  description = var.nfs.description
  volume_type = var.nfs.volume_type
  size        = var.nfs.disk_size
}
