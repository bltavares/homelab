job "activepub" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
    }

    service {
      name = "fedi"
      port = "web"
      tags = [
        "gateway.enable=true",
        "gateway.name=fedi",
      ]
    }

    volume "persistence" {
      type            = "csi"
      source          = "linstor-activepub"
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
        data        = <<-ini
GTS_TRUSTED_PROXIES={{key "authProxy/network_range"}}
GTS_ADVANCED_RATE_LIMIT_EXCEPTIONS="192.168.15.0/24"
GTS_STORAGE_S3_ACCESS_KEY={{key "aricanduva/access_key"}}
GTS_STORAGE_S3_SECRET_KEY={{key "aricanduva/secret_key"}}
ini
        destination = "secrets/config.env"
        env         = true
      }

      kill_signal = "SIGKILL"

      service {
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
