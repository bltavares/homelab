job "lab" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "romulus"
  }

  group "service" {
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "admin" {}

      port "proxyAuth" {
        to = 4181
      }

      port "git" {
        static = 222
      }
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    service {
      name = "lab-traefik"
      port = "admin"
    }

    service {
      name = "login"
      port = "proxyAuth"
    }

    volume "storage" {
      type            = "csi"
      source          = "traefik-lab"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "service" {
      driver = "docker"
      config {
        image        = "public.ecr.aws/docker/library/traefik:latest"
        ports        = ["admin", "http", "https"]
        network_mode = "host"
        mount {
          type   = "bind"
          source = "local"
          target = "/etc/traefik"
        }
      }

      service {
        check {
          name     = "alive"
          type     = "tcp"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }


      restart {
        attempts = 10
        delay    = "10s"
        interval = "30s"
        mode     = "delay"
      }

      volume_mount {
        volume      = "storage"
        destination = "/storage"
      }

      template {
        destination = "local/traefik.toml"
        data        = <<-TOML
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
    sans = ["*.lab.bltavares.com", "aricanduva.bltavares.com", "id.bltavares.com"]

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
TOML
      }

      template {
        destination = "local/dynamic/mediacenter.toml"
        change_mode = "noop"
        data        = <<-TOML
[http.routers.radarr]
rule = "Host(`radarr.lab.bltavares.com`)"
service = "radarr"
[[http.services.radarr.loadBalancer.servers]]
url = "http://10.147.17.110:7878"

[http.routers.sonarr]
rule = "Host(`sonarr.lab.bltavares.com`)"
service = "sonarr"
[[http.services.sonarr.loadBalancer.servers]]
url = "http://10.147.17.110:8989"

[http.routers.transmission]
rule = "Host(`transmission.lab.bltavares.com`)"
service = "transmission"
[[http.services.transmission.loadBalancer.servers]]
url = "http://10.147.17.110:9091"
TOML
      }

      template {
        destination = "local/dynamic/nodes.toml"
        change_mode = "noop"
        data        = <<-TOML
[http.routers.proxmox]
rule = "Host(`proxmox.lab.bltavares.com`)"
service = "proxmox"
[http.services.proxmox.loadBalancer]
serversTransport = "insecureHttps"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.2:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.3:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.4:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.6:8006"


[http.routers.omv]
rule = "Host(`omv.lab.bltavares.com`)"
service = "omv"
[http.services.omv.loadBalancer]
serversTransport = "insecureHttps"
[[http.services.omv.loadBalancer.servers]]
url = "https://omv.zerotier.bltavares.com:443"

[http.serversTransports.insecureHttps]
insecureSkipVerify = true

[http.routers.aricanduva-short]
rule = "Host(`aricanduva.bltavares.com`)"
service = "aricanduva@consulcatalog"

[http.routers.auth-short]
rule = "Host(`id.bltavares.com`)"
service = "id@consulcatalog"
TOML
      }

      template {
        destination = "local/dynamic/secure.toml"
        change_mode = "noop"
        data        = <<-TOML
[http.middlewares.auth.forwardAuth]
    address = "http://{{ env "NOMAD_ADDR_proxyAuth" }}"
    authResponseHeaders = ["X-Forwarded-User"]
TOML
      }

      template {
        data        = <<EOH
CF_DNS_API_TOKEN={{ key "acme/cloudflare/token" }}
EOH
        destination = "secrets/env.sh"
        env         = true
      }

      resources {
        cpu    = 1000
        memory = 80
      }
    }

    task "proxyAuth" {
      driver = "docker"
      config {
        image = "ghcr.io/bltavares/traefik-forward-auth:patch"
        ports = ["proxyAuth"]
      }

      template {
        data        = <<EOH
LOG_LEVEL="debug"

COOKIE_DOMAIN="lab.bltavares.com"
SECRET="{{key "authProxy/cookie_secret"}}"

DEFAULT_PROVIDER="generic-oauth"
PROVIDERS_GENERIC_OAUTH_AUTH_URL="https://discord.com/api/oauth2/authorize"
PROVIDERS_GENERIC_OAUTH_TOKEN_URL="https://discord.com/api/oauth2/token"
PROVIDERS_GENERIC_OAUTH_USER_URL="https://discord.com/api/users/@me"
PROVIDERS_GENERIC_OAUTH_SCOPE="identify email"
PROVIDERS_GENERIC_OAUTH_CLIENT_ID="{{ key "authProxy/discord/id" }}"
PROVIDERS_GENERIC_OAUTH_CLIENT_SECRET="{{ key "authProxy/discord/secret" }}"
AUTH_HOST="login.lab.bltavares.com"

# RULES
DOMAIN="bltavares.com"
CONFIG="{{ env "NOMAD_TASK_DIR" }}/config.ini"
EOH
        destination = "secrets/env.sh"
        env         = true
      }

      template {
        data        = <<EOH
# vaultwarden
rule.vaultwarden.action = allow
rule.vaultwarden.rule = Host(`pass.lab.bltavares.com`)

# Git api
rule.git.action = allow
rule.git.rule = Host(`git.lab.bltavares.com`) && (PathPrefix(`/v2`) || PathPrefix(`/api`) || HeadersRegexp(`User-Agent`, `git/2.+`))
# Trow registry
rule.registry.action = allow
rule.registry.rule = Host(`registry.lab.bltavares.com`)

# ipfs
rule.kubo.action = allow
rule.kubo.rule =  Host(`ipfs.lab.bltavares.com`) ||  Host(`ipfs-gateway.lab.bltavares.com`)

# Calibre + Kobo
rule.calibre_kobo.action = allow
rule.calibre_kobo.rule = Host(`calibre.lab.bltavares.com`) && (PathPrefix(`/kobo`) || PathPrefix(`/opds`))

# Bookmarks
rule.bookmarks.action = allow
rule.bookmarks.rule = Host(`bookmarks.lab.bltavares.com`)

# aricanduva
rule.aricanduva.action = allow
rule.aricanduva.rule = Host(`aricanduva.lab.bltavares.com`) || Host(`aricanduva.bltavares.com`)

# auth
rule.auth.action = allow
rule.auth.rule = Host(`id.lab.bltavares.com`) || Host(`id.bltavares.com`)
EOH
        destination = "local/config.ini"
      }

      resources {
        cpu    = 400
        memory = 50
      }
    }
  }
}
