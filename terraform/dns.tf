variable "cloudflare_email" {}
variable "cloudflare_token" {}

provider "cloudflare" {
  version = "~> 2.6"
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

locals {
  zone_id = lookup(data.cloudflare_zones.zone_info.zones[0], "id")
}

## Archiver

resource "cloudflare_record" "archiver-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.archiver.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.archiver.zt6plane_address
}

resource "cloudflare_record" "archiver-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.archiver.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.archiver.rfc4193_address
}

resource "cloudflare_record" "archiver-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.archiver.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.archiver.ipv4_assignments), 0)
}

## vaporware

resource "cloudflare_record" "vaporware-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.vaporware.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.vaporware.zt6plane_address
}

resource "cloudflare_record" "vaporware-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.vaporware.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.vaporware.rfc4193_address
}

resource "cloudflare_record" "vaporware-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.vaporware.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.vaporware.ipv4_assignments), 0)
}

## libreelec

resource "cloudflare_record" "libreelec-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.libreelec.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.libreelec.zt6plane_address
}

resource "cloudflare_record" "libreelec-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.libreelec.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.libreelec.rfc4193_address
}

resource "cloudflare_record" "libreelec-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.libreelec.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.libreelec.ipv4_assignments), 0)
}

## pve

resource "cloudflare_record" "pve-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve.zt6plane_address
}

resource "cloudflare_record" "pve-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve.rfc4193_address
}

resource "cloudflare_record" "pve-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.pve.ipv4_assignments), 0)
}

## controller

resource "cloudflare_record" "controller-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.controller.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.controller.zt6plane_address
}

resource "cloudflare_record" "controller-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.controller.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.controller.rfc4193_address
}

resource "cloudflare_record" "controller-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.controller.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.controller.ipv4_assignments), 0)
}

## p1

resource "cloudflare_record" "p1-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p1.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p1.zt6plane_address
}

resource "cloudflare_record" "p1-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p1.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p1.rfc4193_address
}

resource "cloudflare_record" "p1-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p1.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.p1.ipv4_assignments), 0)
}

## p2

resource "cloudflare_record" "p2-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p2.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p2.zt6plane_address
}

resource "cloudflare_record" "p2-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p2.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p2.rfc4193_address
}

resource "cloudflare_record" "p2-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p2.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.p2.ipv4_assignments), 0)
}

## p3

resource "cloudflare_record" "p3-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p3.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p3.zt6plane_address
}

resource "cloudflare_record" "p3-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p3.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p3.rfc4193_address
}

resource "cloudflare_record" "p3-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p3.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.p3.ipv4_assignments), 0)
}

## p4

resource "cloudflare_record" "p4-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p4.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p4.zt6plane_address
}

resource "cloudflare_record" "p4-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p4.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.p4.rfc4193_address
}

resource "cloudflare_record" "p4-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.p4.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.p4.ipv4_assignments), 0)
}

## pve-debian

resource "cloudflare_record" "pve-debian-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-debian.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve-debian.zt6plane_address
}

resource "cloudflare_record" "pve-debian-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-debian.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve-debian.rfc4193_address
}

resource "cloudflare_record" "pve-debian-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-debian.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.pve-debian.ipv4_assignments), 0)
}

## Lab: Web proxy
resource "cloudflare_record" "lab-6plane" {
  zone_id = local.zone_id
  name    = "*.lab"
  type    = "AAAA"
  value   = zerotier_member.pve-debian.zt6plane_address
}

resource "cloudflare_record" "lab-rfc" {
  zone_id = local.zone_id
  name    = "*.lab"
  type    = "AAAA"
  value   = zerotier_member.pve-debian.rfc4193_address
}

resource "cloudflare_record" "lab-dhcp" {
  zone_id = local.zone_id
  name    = "*.lab"
  type    = "A"
  value   = element(tolist(zerotier_member.pve-debian.ipv4_assignments), 0)
}

## pve-dat

resource "cloudflare_record" "pve-dat-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-dat.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve-dat.zt6plane_address
}

resource "cloudflare_record" "pve-dat-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-dat.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.pve-dat.rfc4193_address
}

resource "cloudflare_record" "pve-dat-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.pve-dat.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.pve-dat.ipv4_assignments), 0)
}

## openwisp

resource "cloudflare_record" "openwisp-6plane" {
  zone_id = local.zone_id
  name    = "${zerotier_member.openwisp.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.openwisp.zt6plane_address
}

resource "cloudflare_record" "openwisp-rfc" {
  zone_id = local.zone_id
  name    = "${zerotier_member.openwisp.name}.zerotier"
  type    = "AAAA"
  value   = zerotier_member.openwisp.rfc4193_address
}

resource "cloudflare_record" "openwisp-dhcp" {
  zone_id = local.zone_id
  name    = "${zerotier_member.openwisp.name}.zerotier"
  type    = "A"
  value   = element(tolist(zerotier_member.openwisp.ipv4_assignments), 0)
}
