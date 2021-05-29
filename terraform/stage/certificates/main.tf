terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
      version = "~> 2.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }

  backend "remote" {
    organization = "homelab"

    workspaces {
      name = "certificates"
    }
  }
}

provider "acme" {
  #  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "acme_registration" "registration" {
  account_key_pem = file("../../../secrets/acme-registration.key")
  email_address   = var.acme-user
}
