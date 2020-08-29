module "web-proxy" {
  source       = "../../../../modules/dns"
  zone_id      = data.terraform_remote_state.network.outputs.zone_id
  domain       = "*.lab"
  zt_addresses = module.member.addresses
}

resource "local_file" "lab-config" {
  filename = "../../../../../kickstart/files/lab-traefik.toml"
  content = templatefile("templates/lab-traefik.toml.tmpl", {
    radarr       = element(tolist(module.member.addresses.ipv4_assignments), 0),
    sonarr       = element(tolist(module.member.addresses.ipv4_assignments), 0),
    transmission = element(tolist(module.member.addresses.ipv4_assignments), 0),
  })
}
