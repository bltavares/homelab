provider "acme" {
  version = "1.0.0-wip" # https://github.com/bltavares/terraform-provider-acme
  #  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme-user" {}

resource "acme_registration" "registration" {
  account_key_pem = file("../secrets/acme-registration.key")
  email_address   = var.acme-user
}

resource "acme_certificate" "lab-certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = "*.lab.bltavares.com"
  subject_alternative_names = ["lab.bltavares.com"]

  dns_challenge {
    provider = "cloudflare"

    config = {
      CLOUDFLARE_EMAIL   = var.cloudflare_email
      CLOUDFLARE_API_KEY = var.cloudflare_token
    }
  }
}

resource "local_file" "lab-certificate" {
  sensitive_content = acme_certificate.lab-certificate.certificate_pem
  filename          = "../kickstart/files/certificates/lab.bltavares.com.cert"
}

resource "local_file" "lab-private-key" {
  sensitive_content = acme_certificate.lab-certificate.private_key_pem
  filename          = "../kickstart/files/certificates/lab.bltavares.com.key"
}
