variable "zerotier_api_key" {}

variable "zerotier_network" {
  type = map(object({
    first  = string,
    last   = string,
    target = string,
  }))
}

provider "zerotier" {
  api_key = var.zerotier_api_key
  version = "0.2.0-wip" # https://github.com/bltavares/terraform-provider-zerotier#wip
}

resource "zerotier_network" "homelab" {
  name         = "zerotier.bltavares.com"
  rules_source = file("../secrets/zerotier.config")

  auto_assign_v4     = true
  auto_assign_6plane = true
  auto_assign_v6     = true

  dynamic "assignment_pool" {
    for_each = var.zerotier_network
    content {
      first = assignment_pool.value.first
      last  = assignment_pool.value.last
    }
  }

  dynamic "route" {
    for_each = var.zerotier_network
    content {
      target = route.value.target
    }
  }
}

variable "zerotier_members" {
  type = map(object({
    node_id        = string,
    assignment_ips = list(string)
  }))
}

resource "zerotier_member" "vaporware" {
  node_id    = var.zerotier_members.vaporware.node_id
  network_id = zerotier_network.homelab.id
  name       = "vaporware"

  ip_assignments = var.zerotier_members.vaporware.assignment_ips
}

resource "zerotier_member" "archiver" {
  node_id    = var.zerotier_members.archiver.node_id
  network_id = zerotier_network.homelab.id
  name       = "archiver"

  ip_assignments = var.zerotier_members.archiver.assignment_ips
}

resource "zerotier_member" "libreelec" {
  node_id    = var.zerotier_members.libreelec.node_id
  network_id = zerotier_network.homelab.id
  name       = "libreelec"

  ip_assignments = var.zerotier_members.libreelec.assignment_ips
}

resource "zerotier_member" "pve" {
  node_id    = var.zerotier_members.pve.node_id
  network_id = zerotier_network.homelab.id
  name       = "pve"

  ip_assignments = var.zerotier_members.pve.assignment_ips
}

resource "zerotier_member" "pve-debian" {
  node_id    = var.zerotier_members.pve-debian.node_id
  network_id = zerotier_network.homelab.id
  name       = "pve-debian"

  ip_assignments = var.zerotier_members.pve-debian.assignment_ips
}

resource "zerotier_member" "controller" {
  node_id    = var.zerotier_members.controller.node_id
  network_id = zerotier_network.homelab.id
  name       = "controller"

  ip_assignments = var.zerotier_members.controller.assignment_ips
}

resource "zerotier_member" "p1" {
  node_id    = var.zerotier_members.p1.node_id
  network_id = zerotier_network.homelab.id
  name       = "p1"

  ip_assignments = var.zerotier_members.p1.assignment_ips
}

resource "zerotier_member" "p2" {
  node_id    = var.zerotier_members.p2.node_id
  network_id = zerotier_network.homelab.id
  name       = "p2"

  ip_assignments = var.zerotier_members.p2.assignment_ips
}

resource "zerotier_member" "p3" {
  node_id    = var.zerotier_members.p3.node_id
  network_id = zerotier_network.homelab.id
  name       = "p3"

  ip_assignments = var.zerotier_members.p3.assignment_ips
}

resource "zerotier_member" "p4" {
  node_id    = var.zerotier_members.p4.node_id
  network_id = zerotier_network.homelab.id
  name       = "p4"

  ip_assignments = var.zerotier_members.p4.assignment_ips
}

resource "zerotier_member" "pve-dat" {
  node_id    = var.zerotier_members.pve-dat.node_id
  network_id = zerotier_network.homelab.id
  name       = "pve-dat"

  ip_assignments = var.zerotier_members.pve-dat.assignment_ips
}
