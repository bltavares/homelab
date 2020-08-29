
provider "zerotier" {
  api_key = var.zerotier_api_key
}

resource "zerotier_network" "homelab" {
  name         = "zerotier.bltavares.com"
  rules_source = file("../../../secrets/zerotier.config")

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

output "id" {
  value = zerotier_network.homelab.id
}
