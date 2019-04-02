variable "cloudflare_email" {}
variable "cloudflare_token" {}

provider "cloudflare" {
  version = "1.12.0-wip" # https://github.com/bltavares/terraform-provider-cloudflare
  email   = var.cloudflare_email
  token   = var.cloudflare_token
}

## Archiver

resource "cloudflare_record" "archiver-6plane" {
  domain = "bltavares.com"
  name   = "${zerotier_member.archiver.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.archiver["6plane_address"]
}

resource "cloudflare_record" "archiver-rfc" {
  domain = "bltavares.com"
  name   = "${zerotier_member.archiver.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.archiver.rfc4193_address
}

resource "cloudflare_record" "archiver-dhcp" {
  domain = "bltavares.com"
  name   = "${zerotier_member.archiver.name}.zerotier"
  type   = "A"
  value  = element(tolist(zerotier_member.archiver.ipv4_assignments), 0)
}

## vaporware

resource "cloudflare_record" "vaporware-6plane" {
  domain = "bltavares.com"
  name   = "${zerotier_member.vaporware.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.vaporware["6plane_address"]
}

resource "cloudflare_record" "vaporware-rfc" {
  domain = "bltavares.com"
  name   = "${zerotier_member.vaporware.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.vaporware.rfc4193_address
}

resource "cloudflare_record" "vaporware-dhcp" {
  domain = "bltavares.com"
  name   = "${zerotier_member.vaporware.name}.zerotier"
  type   = "A"
  value  = element(tolist(zerotier_member.vaporware.ipv4_assignments), 0)
}

## libreelec

resource "cloudflare_record" "libreelec-6plane" {
  domain = "bltavares.com"
  name   = "${zerotier_member.libreelec.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.libreelec["6plane_address"]
}

resource "cloudflare_record" "libreelec-rfc" {
  domain = "bltavares.com"
  name   = "${zerotier_member.libreelec.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.libreelec.rfc4193_address
}

resource "cloudflare_record" "libreelec-dhcp" {
  domain = "bltavares.com"
  name   = "${zerotier_member.libreelec.name}.zerotier"
  type   = "A"
  value  = element(tolist(zerotier_member.libreelec.ipv4_assignments), 0)
}

## pve

resource "cloudflare_record" "pve-6plane" {
  domain = "bltavares.com"
  name   = "${zerotier_member.pve.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.pve["6plane_address"]
}

resource "cloudflare_record" "pve-rfc" {
  domain = "bltavares.com"
  name   = "${zerotier_member.pve.name}.zerotier"
  type   = "AAAA"
  value  = zerotier_member.pve.rfc4193_address
}

resource "cloudflare_record" "pve-dhcp" {
  domain = "bltavares.com"
  name   = "${zerotier_member.pve.name}.zerotier"
  type   = "A"
  value  = element(tolist(zerotier_member.pve.ipv4_assignments), 0)
}

## Lab: Web proxy
resource "cloudflare_record" "lab-6plane" {
  domain = "bltavares.com"
  name   = "*.lab"
  type   = "AAAA"
  value  = zerotier_member.pve["6plane_address"]
}

resource "cloudflare_record" "lab-rfc" {
  domain = "bltavares.com"
  name   = "*.lab"
  type   = "AAAA"
  value  = zerotier_member.pve.rfc4193_address
}

resource "cloudflare_record" "lab-dhcp" {
  domain = "bltavares.com"
  name   = "*.lab"
  type   = "A"
  value  = element(tolist(zerotier_member.pve.ipv4_assignments), 0)
}
