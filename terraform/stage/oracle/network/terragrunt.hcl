terraform {
  extra_arguments "default_vars" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = ["${get_terragrunt_dir()}/../../../../secrets/production.tfvars"]
  }

  extra_arguments "backend" {
    commands = ["init"]
    arguments = [
      "-backend-config=${get_terragrunt_dir()}/../../../../secrets/config.consul.tfbackend"
    ]
  }
}
