terraform {
  required_providers {
    cloudflare = {
      source = "terraform-providers/cloudflare"
      version = "~> 2.9.0"
    }
  }
  required_version = ">= 0.13"
}
