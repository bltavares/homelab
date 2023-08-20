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
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "image" {
      driver = "docker"

      service {
        check {
          type     = "http"
          path     = "/api/healthz"
          port     = "web"
          interval = "30s"
          timeout  = "1s"
        }
      }

      config {
        image = "registry.lab.bltavares.com/gitea/gitea"
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

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}