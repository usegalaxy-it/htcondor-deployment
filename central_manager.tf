resource "openstack_compute_instance_v2" "central-manager" {
  name            = "${var.name_prefix}central-manager"
  flavor_name     = var.flavors.central-manager
  image_id        = data.openstack_images_image_v2.htcondor-image.id
  key_pair        = openstack_compute_keypair_v2.cloud-key.name
  security_groups = var.secgroups_cm
  # depends_on      = [openstack_compute_instance_v2.nfs-server]

  network {
    uuid = data.openstack_networking_network_v2.internal.id
  }

  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u rocky -b -i '${self.access_ip_v4},' --private-key ${var.pvt_key} --extra-vars='condor_host=${self.access_ip_v4} condor_ip_range=${var.private_network.cidr4} condor_password=${var.condor_pass}' condor-install-cm.yml"
  }

  user_data = data.template_file.cm_user_data.rendered
}

resource "openstack_networking_floatingip_v2" "pub_ip" {
  pool = var.public_network.name
}

resource "openstack_compute_floatingip_associate_v2" "pub_ip" {
  floating_ip = openstack_networking_floatingip_v2.pub_ip.address
  instance_id = openstack_compute_instance_v2.central-manager.id
  fixed_ip    = openstack_compute_instance_v2.central-manager.network.0.fixed_ip_v4
}

