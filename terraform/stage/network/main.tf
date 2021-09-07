terraform {
  required_providers {
    zerotier = {
      source  = "zerotier/zerotier"
      version = "~> 1.0.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.10.0"
    }
  }

  backend "remote" {
    organization = "homelab"

    workspaces {
      name = "network"
    }
  }
}

