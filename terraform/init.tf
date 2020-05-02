terraform {
  required_version = "~> 0.12.24"
  backend "remote" {
    organization = "homelab"

    workspaces {
      name = "production"
    }
  }
}
