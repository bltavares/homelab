terraform {
  required_providers {
    zerotier = {
      source  = "bltavares/zerotier"
      version = "~> 0.3.0"
    }
    cloudflare = {
      source  = "terraform-providers/cloudflare"
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

