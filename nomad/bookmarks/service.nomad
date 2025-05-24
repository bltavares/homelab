job "bookmarks" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 9090 }
    }

    service {
      name = "bookmarks"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "bookmarks"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/sissbruecker/linkding:latest"
        # image = "ghcr.io/sissbruecker/linkding:latest"

        ports = ["web"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/etc/linkding/data"
      }

      env {

      }

      # service {
      #   check {
      #     name     = "Service Check"
      #     type     = "script"
      #     command  = "/usr/bin/miniflux"
      #     args     = ["-healthcheck", "auto"]
      #     interval = "1m"
      #     timeout  = "30s"

      #     check_restart {
      #       limit = 10
      #       grace = "5m"
      #     }
      #   }

      //   check {
      //     name      = "startup check"
      //     type      = "tcp"
      //     port      = "web"
      //     interval  = "10s"
      //     timeout   = "30s"
      //     on_update = "ignore_warnings"
      //   }
      # }

      // restart {
      //   attempts = 5
      //   delay    = "1m"
      //   interval = "10m"
      //   mode     = "fail"
      // }

      resources {
        cpu    = 200
        memory = 500
      }
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--token", file("../../secrets/bookmarks/tunnel.token"),
          "--url", "${NOMAD_ADDR_web}",
          "bookmarks",
        ]
      }

      resources {
        cpu    = 50
        memory = 50
      }
    }

  }

}