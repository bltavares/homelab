terraform {
  extra_arguments "default_vars" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = ["${get_terragrunt_dir()}/../../../../secrets/production.tfvars"]
  }
}
