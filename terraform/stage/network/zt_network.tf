
provider "zerotier" {
  zerotier_central_token = var.zerotier_api_key
}

resource "zerotier_network" "homelab" {
  name         = "zerotier.bltavares.com"
  flow_rules = file("../../../secrets/zerotier.config")

  assign_ipv4  {
    zerotier = true
  }
  assign_ipv6 {
    zerotier = true
    sixplane = true
    rfc4193 = true
  }

  dynamic "assignment_pool" {
    for_each = var.zerotier_network
    content {
      start = assignment_pool.value.first
      end  = assignment_pool.value.last
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
