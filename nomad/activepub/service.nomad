job "activepub" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8000 }
    }

    service {
      name = "pub"
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
        image = "registry.lab.bltavares.com/bltavares/microblogpub:latest"
        ports = ["web"]
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
        destination = "/app/data"
      }

      resources {
        cpu    = 100
        memory = 800
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