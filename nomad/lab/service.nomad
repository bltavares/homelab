job "lab" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "ryzen"
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
        data        = file("./config/static.toml.tpl")
        destination = "local/traefik.toml"
      }

      template {
        data        = file("./config/mediacenter.toml")
        destination = "local/dynamic/mediacenter.toml"
        change_mode = "noop"
      }

      template {
        data        = file("./config/nodes.toml")
        destination = "local/dynamic/nodes.toml"
        change_mode = "noop"
      }
      template {
        data        = file("./config/secure.toml.tpl")
        destination = "local/dynamic/secure.toml"
        change_mode = "noop"
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
# Gitea registry
rule.gitea.action = allow
rule.gitea.rule = Host(`gitea.lab.bltavares.com`) && (PathPrefix(`/v2`) || PathPrefix(`/api`))
# Trow registry
rule.registry.action = allow
rule.registry.rule = Host(`registry.lab.bltavares.com`)

# ipfs
rule.kubo.action = allow
rule.kubo.rule =  Host(`ipfs.lab.bltavares.com`) ||  Host(`ipfs-gateway.lab.bltavares.com`)
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
