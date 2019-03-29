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
