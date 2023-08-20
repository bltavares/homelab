generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.110.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.10.0"
    }
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

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_token
}
EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
    backend "remote" {
      organization = "homelab"
      workspaces {
        name = "instance-oracle-${path_relative_to_include()}"
      }
    }
  }
EOF
}

generate "images" {
  path = "images.tf"
  if_exists = "overwrite_terragrunt"

}

terraform {
  extra_arguments "default_vars" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = ["${get_terragrunt_dir()}/../../../../secrets/production.tfvars"]
  }
}

download_dir = "${get_parent_terragrunt_dir()}/../../../terragrunt/.terragrunt-cache"
skip         = true
