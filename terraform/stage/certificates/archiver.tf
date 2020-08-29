
resource "acme_certificate" "archiver-certificate" {
  account_key_pem    = acme_registration.registration.account_key_pem
  common_name        = "archiver.zerotier.bltavares.com"
  min_days_remaining = 10

  dns_challenge {
    provider = "cloudflare"

    config = {
      CLOUDFLARE_EMAIL   = var.cloudflare_email
      CLOUDFLARE_API_KEY = var.cloudflare_token
    }
  }
}

resource "local_file" "archiver-certificate" {
  sensitive_content = acme_certificate.archiver-certificate.certificate_pem
  filename          = "../../../kickstart/files/certificates/archiver.zerotier.bltavares.com.cert"
}

resource "local_file" "archiver-private-key" {
  sensitive_content = acme_certificate.archiver-certificate.private_key_pem
  filename          = "../../../kickstart/files/certificates/archiver.zerotier.bltavares.com.key"
}
