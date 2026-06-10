[log]
#  level = "DEBUG"

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
[entryPoints.ssl.http.tls]
  certResolver = "letsencrypt"
[[entryPoints.ssl.http.tls.domains]]
    main = "gateway.bltavares.com"

[certificatesResolvers.letsencrypt.acme]
  email = "{{ key "acme/email" }}"
  storage = "/storage/acme.json"
[certificatesResolvers.letsencrypt.acme.dnsChallenge]
  provider = "cloudflare"

[providers.file]
  directory = "/etc/traefik/dynamic"

[providers.consulCatalog]
    exposedByDefault = false
    prefix = "gateway"
    defaultRule = "Host(`{{"{{ coalesce (index .Labels \\\"traefik.name\\\") .Name }}"}}.bltavares.com`)"
    endpoint = { address = "localhost:8500" }
