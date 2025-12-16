generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "zerotier" {
  api_key = var.zerotier_api_key
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
  backend "consul" {
    path = "terraform/network-members/${path_relative_to_include()}/state"
    gzip = true
  }
}
EOF
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../../terragrunt/network_members"

  extra_arguments "default_vars" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = ["${get_parent_terragrunt_dir()}/../../../secrets/production.tfvars"]
  }

  extra_arguments "backend" {
    commands = ["init"]
    arguments = [
      "-backend-config=${get_parent_terragrunt_dir()}/../../../secrets/config.consul.tfbackend"
    ]
  }
}

download_dir = "${get_parent_terragrunt_dir()}/../../terragrunt/.terragrunt-cache"