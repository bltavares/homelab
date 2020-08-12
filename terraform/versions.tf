terraform {
  required_providers {
    acme = {
      source  = "terraform-providers/acme"
      version = "~> 1.5.0"
    }
    cloudflare = {
      source  = "terraform-providers/cloudflare"
      version = "~> 2.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4.0"
    }
    zerotier = {
      source  = "bltavares/zerotier"
      version = "~> 0.3.0"
    }
  }
  required_version = ">= 0.13"
}
