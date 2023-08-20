storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

telemetry {
  statsite_address = "0.0.0.0:8125"
  disable_hostname = true
}

ui = true