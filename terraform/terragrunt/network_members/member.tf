module "member" {
  source = "../../../../modules/network_member"

  zerotier_member     = merge(var.zerotier_members[var.name], { name = var.name })
  zerotier_network_id = data.terraform_remote_state.network.outputs.id
  zone_id             = data.terraform_remote_state.network.outputs.zone_id
}
