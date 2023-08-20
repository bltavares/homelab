job "music" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" {}
      port "mpd" {}

      port "snapcast_listen" {}
      port "snapcast_http" {}
      port "snapcast_tcp" {}
    }

    service {
      name = "music"
      port = "web"
    }

    service {
      name = "audio"
      port = "snapcast_http"
    }

    service {
      name = "mpd"
      port = "mpd"
    }

    volume "storage" {
      type            = "csi"
      source          = "iris"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "iris" {
      driver = "docker"

      config {
        image = "bltavares/iris"
        ports = ["web", "mpd"]

        mount {
          type   = "bind"
          source = "local"
          target = "/config"
        }
      }

      env {
        # Fixes for ytmusic bugs until the image contains the updates
        PIP_PACKAGES = "mopidy-ytmusic ytmusicapi==0.20.0 pytube"
      }

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      template {
        data        = file("./mopidy.conf")
        destination = "local/mopidy.conf"
      }

      template {
        data = file("../../secrets/ytmusic.json")
        destination = "secrets/ytmusic.json"
      }

      resources {
        cpu    = 500
        memory = 500
        disk   = 1
      }
    }

    task "snapserver" {
      driver = "docker"

      config {
        image = "jaedb/snapserver"
        ports = ["snapcast_listen", "snapcast_http", "snapcast_tcp"]

        mount {
          type   = "bind"
          source = "local/snapserver.conf"
          target = "/etc/snapserver.conf"
        }
      }

      template {
        data        = file("./snapserver.conf")
        destination = "local/snapserver.conf"
      }

      resources {
        cpu    = 100
        memory = 100
        disk   = 1
      }
    }
  }
}