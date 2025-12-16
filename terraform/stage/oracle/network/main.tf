terraform {
  required_providers {
    zerotier = {
      source  = "bltavares/zerotier"
      version = "~> 0.3.0"
    }

    oci = {
      source  = "oracle/oci"
      version = "4.110.0"
    }

  }

  backend "consul" {
    path = "terraform/oracle/network/state"
    gzip = true
  }
}


provider "oci" {
  tenancy_ocid     = var.oci_profile.tenancy
  user_ocid        = var.oci_profile.user
  private_key_path = var.oci_profile.key_file
  fingerprint      = var.oci_profile.fingerprint
  region           = var.oci_profile.region
}

variable "oci_profile" {
  type = object({
    tenancy     = string
    user        = string
    key_file    = string
    fingerprint = string
    region      = string
    compartment = string
  })
}
