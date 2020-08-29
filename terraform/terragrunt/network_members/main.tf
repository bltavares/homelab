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
}

data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "homelab"
    workspaces = {
      name = "network"
    }
  }
}
