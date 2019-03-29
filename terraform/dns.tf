variable "cloudflare_email" {}
variable "cloudflare_token" {}

provider "cloudflare" {
  version = "1.12.0-wip" # https://github.com/bltavares/terraform-provider-cloudflare
  email   = var.cloudflare_email
  token   = var.cloudflare_token
}

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
