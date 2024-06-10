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
    }

    volume "storage" {
      type            = "csi"
      source          = "activepub"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "image" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/superseriousbusiness/gotosocial:latest"
        ports = ["web"]
      }

      env {
        GTS_HOST                      = "fedi.bltavares.com"
        GTS_DB_TYPE                   = "sqlite"
        GTS_DB_ADDRESS                = "/gotosocial/storage/gotosocial.sqlite.db"
        GTS_LANDING_PAGE_USER         = "bltavares"
        GTS_ACCOUNTS_ALLOW_CUSTOM_CSS = "true"
        TZ                            = "UTC"
        GTS_TRUSTED_PROXIES           = "172.17.0.1/24"
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
        volume      = "storage"
        destination = "/gotosocial/storage"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--token", file("../../secrets/activitypub/tunnel.token"),
          "--url", "${NOMAD_ADDR_web}",
          "activitypub",
        ]
      }

      resources {
        cpu    = 10
        memory = 50
      }
    }
  }
}