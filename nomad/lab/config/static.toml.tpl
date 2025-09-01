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
[entryPoints.ssl.http]
  middlewares = ["auth@file"]
[entryPoints.ssl.http.tls]
  certResolver = "letsencrypt"
[[entryPoints.ssl.http.tls.domains]]
    main = "lab.bltavares.com"
    sans = ["*.lab.bltavares.com"]

[entryPoints.git]
  address = ":222"

[certificatesResolvers.letsencrypt.acme]
  email = "{{ key "acme/email" }}"
  storage = "/storage/acme.json"
[certificatesResolvers.letsencrypt.acme.dnsChallenge]
  provider = "cloudflare"

[providers.file]
  directory = "/etc/traefik/dynamic"

[providers.consulCatalog]
    defaultRule = "Host(`{{"{{ normalize .Name }}"}}.lab.bltavares.com`)"
    endpoint = { address = "localhost:8500" }