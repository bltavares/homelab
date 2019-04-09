data_dir = "/opt/nomad"

bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"fc36:152b:7a00::/40\" | attr \"address\"}}"

client {
  enabled = true
}
