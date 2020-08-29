module "web-proxy" {
  source       = "../../../../modules/dns"
  zone_id      = data.terraform_remote_state.network.outputs.zone_id
  domain       = "*.lab"
  zt_addresses = module.member.addresses
}
