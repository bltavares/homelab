job "ssb-room" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 3000 }
      port "ssb" { to = 8008 }
    }

    service {
      name = "ssb-room"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "ssb-room"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "image" {
      driver = "docker"

      config {
        image = "bltavares/go-ssb-room"
        ports = ["web", "ssb"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/ssb-go-room-secrets"
      }

      env {
        HTTPS_DOMAIN          = "ssb-room.lab.bltavares.com"
        ALIASES_AS_SUBDOMAINS = false
        REPO                  = "/ssb-go-room-secrets"
      }
    }
  }
}