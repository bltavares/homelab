job "gitea" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 3000 }
      port "ssh" { to = 22 }
    }

    service {
      name = "gitea"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "gitea"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "image" {
      driver = "docker"

      config {
        image = "gitea/gitea:1.15.3"
        ports = ["web", "ssh"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      env {
        USER_GID  = 1000
        GROUP_GID = 1000
      }
    }
  }
}