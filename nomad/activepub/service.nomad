job "activepub" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
    }

    volume "persistence" {
      type            = "csi"
      source          = "linstor-activepub"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/superseriousbusiness/gotosocial:latest"
        ports = ["web"]
        init  = true
      }

      env {
        GTS_HOST       = "fedi.bltavares.com"
        GTS_DB_TYPE    = "sqlite"
        GTS_DB_ADDRESS = "/gotosocial/storage/gotosocial.sqlite.db"
        # GTS_DB_SQLITE_JOURNAL_MODE    = "DELETE"
        # GTS_DB_SQLITE_SYNCHRONOUS     = "NORMAL"
        GTS_LANDING_PAGE_USER         = "bltavares"
        GTS_ACCOUNTS_ALLOW_CUSTOM_CSS = "true"
        TZ                            = "UTC"

        GTS_STORAGE_BACKEND         = "s3"
        GTS_STORAGE_S3_PROXY        = "false"
        GTS_STORAGE_S3_ENDPOINT     = "aricanduva.bltavares.com"
        GTS_STORAGE_S3_USE_SSL      = "true"
        GTS_STORAGE_S3_BUCKET       = "gotosocial"
        GTS_ADVANCED_CSP_EXTRA_URIS = "dweb.link,*.dweb.link"
      }

      template {
        destination = "secrets/config.env"
        env         = true
        data        = <<-INI
GTS_TRUSTED_PROXIES={{key "authProxy/network_range"}}
GTS_ADVANCED_RATE_LIMIT_EXCEPTIONS="192.168.15.0/24"

# Aricanduva secrets
GTS_STORAGE_S3_ACCESS_KEY={{key "aricanduva/access_key"}}
GTS_STORAGE_S3_SECRET_KEY={{key "aricanduva/secret_key"}}

# OIDC
GTS_OIDC_ENABLED=true
GTS_OIDC_IDP_NAME='Homelab'
GTS_OIDC_ISSUER="https://id.bltavares.com/auth/v1/"
GTS_OIDC_CLIENT_ID=gotosocial
GTS_OIDC_CLIENT_SECRET="{{ key "gotosocial/oidc_secret" }}"
GTS_OIDC_LINK_EXISTING=true
INI
      }

      service {
        name = "fedi"
        port = "web"
        tags = [
          "gateway.enable=true",
          "oidc",
        ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/livez"
          port     = "web"
          interval = "5m"
          timeout  = "10s"
        }

        check_restart {
          limit           = 3
          grace           = "90s"
          ignore_warnings = false
        }
      }

      volume_mount {
        volume      = "persistence"
        destination = "/gotosocial/storage"
      }

      resources {
        cpu    = 1500
        memory = 1500
      }
    }

    task "permission-fix" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "registry.lab.bltavares.com/alpine:latest"
        args  = ["chown", "1000:1000", "/mnt/data"]
      }
      volume_mount {
        volume      = "persistence"
        destination = "/mnt/data"
      }
    }
  }
}
