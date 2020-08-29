terraform {
  required_providers {
    zerotier = {
      source  = "bltavares/zerotier"
      version = "~> 0.3.0"
    }
  }
}

resource "zerotier_member" "node" {
  node_id        = var.zerotier_member.node_id
  network_id     = var.zerotier_network_id
  name           = var.zerotier_member.name
  ip_assignments = var.zerotier_member.assignment_ips
}

module "dns" {
  source       = "../dns"
  zone_id      = var.zone_id
  domain       = "${var.zerotier_member.name}.zerotier"
  zt_addresses = zerotier_member.node
}
