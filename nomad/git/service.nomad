job "git" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 3000 }
      port "ssh" { to = 22 }
    }

    service {
      name = "git"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "git"
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
        image      = "registry.lab.bltavares.com/forgejo/forgejo:11"
        force_pull = true
        ports      = ["web", "ssh"]
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
        memory = 1024
      }
    }
  }
}