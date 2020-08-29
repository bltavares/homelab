terraform {
  required_providers {
    acme = {
      source  = "terraform-providers/acme"
      version = "~> 1.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4.0"
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
