resource "openstack_networking_secgroup_v2" "public-ssh" {
  name                 = "htcondor-public-ssh"
  description          = "[tf] Allow SSH connections from anywhere"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "public-ssh-4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh-port
  port_range_max    = var.ssh-port
  security_group_id = openstack_networking_secgroup_v2.public-ssh.id
}

resource "openstack_networking_secgroup_rule_v2" "publich-ssh-6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.ssh-port
  port_range_max    = var.ssh-port
  security_group_id = openstack_networking_secgroup_v2.public-ssh.id
}
