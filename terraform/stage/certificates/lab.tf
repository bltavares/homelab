resource "acme_certificate" "lab-certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  common_name               = "*.lab.bltavares.com"
  subject_alternative_names = ["lab.bltavares.com"]
  min_days_remaining        = 10

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
  filename          = "../../../kickstart/files/certificates/lab.bltavares.com.cert"
}

resource "local_file" "lab-private-key" {
  sensitive_content = acme_certificate.lab-certificate.private_key_pem
  filename          = "../../../kickstart/files/certificates/lab.bltavares.com.key"
}

resource "local_file" "lab-fullchain" {
  sensitive_content = "${acme_certificate.lab-certificate.certificate_pem}${acme_certificate.lab-certificate.issuer_pem}"
  filename          = "../../../kickstart/files/certificates/lab.bltavares.com.fullchain.cert"
}
