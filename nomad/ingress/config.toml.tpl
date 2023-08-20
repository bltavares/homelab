[log]
  level = "DEBUG"

[entrypoints.traefik]
 address = "{{ env "NOMAD_ADDR_admin" }}"

[api]
  dashboard = true
  insecure = true

[entryPoints.web]
  address = ":80"

[entryPoints.web.http.redirections.entryPoint]
    to = "ssl"
    scheme = "https"

[entryPoints.ssl]
  address = ":443"

[entryPoints.ssb-shs]
  address = ":8008/tcp"

[providers.file]
  directory = "/etc/traefik/dynamic"