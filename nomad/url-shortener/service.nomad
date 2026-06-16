job "url-shortener" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 4567 }
    }

    volume "storage" {
      type            = "csi"
      source          = "url-shortener"
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
        image = "registry.lab.bltavares.com/sintan1729/chhoto-url:latest"
        ports = ["web"]
      }

      user = "1000:1000"

      env {
        site_url = "z.bltavares.com"
        db_url   = "/config/urls.sqlite"
      }

      template {
        data        = <<EOH
password={{ key "chhoto/password" }}
EOH
        destination = "secrets/env.sh"
        env         = true
      }

      kill_signal = "SIGKILL"

      service {
        name = "z"
        port = "web"

        tags = [
          "gateway.enable=true",
        ]

        check {
          name     = "alive"
          type     = "http"
          path     = "/api/version"
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
        destination = "/config"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
