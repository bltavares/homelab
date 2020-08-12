terraform {
  backend "remote" {
    organization = "homelab"

    workspaces {
      name = "production"
    }
  }
}