job "url-shortener" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 4567 }
    }

    service {
      name = "url-shortener"
      port = "web"
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

    task "image" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/sintan1729/chhoto-url:latest"
        ports = ["web"]
      }

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
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
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
        cpu    = 1500
        memory = 1500
      }
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--token", file("../../secrets/url-shortener/tunnel.token"),
          "--url", "${NOMAD_ADDR_web}",
          "url-shortener",
        ]
      }

      resources {
        cpu    = 50
        memory = 50
      }
    }
  }
}