data_dir = "/opt/nomad"

bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"fc36:152b:7a00::/40\" | attr \"address\"}}"

server {
  enabled          = true
  bootstrap_expect = 3
  encrypt          = "$nomad_key"
}

client {
  enabled           = true
  network_interface = "zt5u44ufvb"
}
