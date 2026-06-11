job "gateway" {
  type        = "service"
  datacenters = ["oracle"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "citadel"
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
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    service {
      name = "gateway-traefik"
      port = "admin"
    }

    volume "storage" {
      type            = "host"
      source          = "traefik-gateway"
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
asDefault = true
http3 = {}
[entryPoints.ssl.http]
middlewares = ["cloudflare@file"]
[entryPoints.ssl.http.tls]
certResolver = "letsencrypt"
[[entryPoints.ssl.http.tls.domains]]
main = "bltavares.com"
sans = ["*.bltavares.com"]

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

[experimental.plugins.cloudflare]
moduleName = "github.com/agence-gaya/traefik-plugin-cloudflare"
version = "v1.2.0"
TOML
      }


      template {
        destination = "local/dynamic/cldouflare.toml"
        data        = <<-TOML
[http.middlewares.cloudflare.plugin.cloudflare]
trustedCIDRs = []
overwriteRequestHeader = true
debug = true
TOML
      }

      template {
        destination = "secrets/env.sh"
        env         = true
        data        = <<-INI
CF_DNS_API_TOKEN={{ key "acme/cloudflare/token" }}
INI
      }

      resources {
        cpu    = 2000
        memory = 120
      }
    }

  }
}
