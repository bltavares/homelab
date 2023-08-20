
provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_token
}

data "cloudflare_zones" "zone_info" {
  filter {
    name   = "bltavares.com"
    status = "active"
    paused = false
  }
}

output "zone_id" {
  value = lookup(data.cloudflare_zones.zone_info.zones[0], "id")
}
