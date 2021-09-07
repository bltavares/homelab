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
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4.0"
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
