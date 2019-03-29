terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    organization = "homelab"

    workspaces {
      name = "production"
    }
  }
}
