job "syncthing" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { static = 8384 }
    }

    service {
      name = "syncthing"
      port = "web"
    }

    volume "config" {
      type            = "csi"
      source          = "syncthing"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    volume "storage" {
      type            = "csi"
      source          = "syncthing-storage"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    update {
      max_parallel = 0
    }

    task "image" {
      driver = "docker"

      config {
        image        = "lscr.io/linuxserver/syncthing"
        ports        = ["web"]
        network_mode = "host"
      }

      volume_mount {
        volume      = "config"
        destination = "/config"
      }

      volume_mount {
        volume      = "storage"
        destination = "/data1"
      }

      env {
        PGID = 0
        PUID = 0
        TZ   = "America/Sao_Paulo"
      }

      service {
        check {
          type     = "tcp"
          port     = "web"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}