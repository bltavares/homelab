
resource "cloudflare_record" "zt6plane" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "AAAA"
  value   = var.zt_addresses.zt6plane_address
}

resource "cloudflare_record" "ztrfc" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "AAAA"
  value   = var.zt_addresses.rfc4193_address
}

resource "cloudflare_record" "ztdhcp" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"
  value   = element(tolist(var.zt_addresses.ipv4_assignments), 0)
}
