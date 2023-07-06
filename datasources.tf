data "openstack_networking_network_v2" "external" {
  name = var.public_network.name
}

data "openstack_networking_network_v2" "internal" {
  name = var.private_network.name
}

data "openstack_images_image_v2" "htcondor-image" {
  name        = openstack_images_image_v2.htcondor-image.name
  most_recent = true
}

data "openstack_compute_keypair_v2" "cloud-key" {
  name = openstack_compute_keypair_v2.cloud-key.name
}

data "cloudinit_config" "nfs-share" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/user_data_nfs.yaml")
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/files/create_share.sh")
  }
}

data "template_file" "cm_user_data" {
  template = file("${path.module}/templates/user_data_cm.yaml")
  vars = {
    nfs_server_ip = openstack_compute_instance_v2.nfs-server.access_ip_v4
    domain_name   = var.domain_name
  }
}

data "template_file" "exec_node_user_data" {
  template = file("${path.module}/templates/user_data_exec.yaml")
  vars = {
    nfs_server_ip  = openstack_compute_instance_v2.nfs-server.access_ip_v4
    condor_host_ip = openstack_compute_instance_v2.central-manager.network.0.fixed_ip_v4
    domain_name    = var.domain_name
    condor_pass    = var.condor_pass
  }
}
