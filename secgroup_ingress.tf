resource "openstack_networking_secgroup_v2" "ingress-private" {
  name                 = "htcondor-ingress-private"
  description          = "[tf] Allow any incoming connection from private network"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ingress-private-4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.private_network.cidr4
  security_group_id = openstack_networking_secgroup_v2.ingress-private.id
}

# resource "openstack_networking_secgroup_rule_v2" "ingress-private-6" {
#   direction         = "ingress"
#   ethertype         = "IPv6"
#   remote_ip_prefix  = var.private_network.cidr4
#   security_group_id = openstack_networking_secgroup_v2.ingress-private.id
# }
