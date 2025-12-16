terraform {
  required_providers {
    zerotier = {
      source  = "bltavares/zerotier"
      version = "~> 0.3.0"
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
  backend = "consul"
  config = {
    path = "terraform/network/state"
    gzip = true
    address = var.consul.address
    access_token = var.consul.access_token
  }
}
