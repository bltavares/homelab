generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "consul" {
    path  = "terraform/${path_relative_to_include()}/state"
    gzip = true
  }
}
EOF
}