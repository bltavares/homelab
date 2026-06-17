job "git" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 3000 }
      port "ssh" { to = 22 }
    }

    volume "storage" {
      type            = "csi"
      source          = "git"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "image" {
      driver = "docker"

      config {
        image      = "registry.lab.bltavares.com/forgejo/forgejo:15"
        force_pull = true
        ports      = ["web", "ssh"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      env {
        USER_GID                  = 1000
        GROUP_GID                 = 1000
        FORGEJO__server__SSH_PORT = 222
      }

      service {
        name = "git"
        port = "web"
        tags = [
          "oidc",
        ]

        check {
          type     = "http"
          path     = "/api/healthz"
          port     = "web"
          interval = "30s"
          timeout  = "1s"
        }
      }

      service {
        name = "git-ssh"
        port = "ssh"
        tags = [
          "traefik.tcp.routers.git-ssh.entrypoints=git",
          "traefik.tcp.routers.git-ssh.rule=HostSNI(`*`)",
        ]
      }

      resources {
        cpu    = 500
        memory = 1024
      }
    }
  }
}
