job "audiobookshelf" {
  type        = "service"
  datacenters = ["dc1"]

  affinity {
    attribute = "${node.unique.name}"
    operator  = "set_contains_any"
    value     = "archiver,pve"
    weight    = -100
  }

  group "service" {
    network {
      port "web" { to = 13378 }
    }

    service {
      name = "audiobooks"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "audiobookshelf"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        # ghcr.io/advplyr/audiobookshelf:latest
        image = "registry.lab.bltavares.com/linuxserver/audiobookshelf-web:latest"
        ports = ["web"]
      }

      # service {
      #  check {
      #    name     = "Service Check"
      #    type     = "http"
      #    path     = "/_audiobookshelf/client/versions"
      #    port     = "conduit"
      #    interval = "10s"
      #    timeout  = "30s"
      #
      #    check_restart {
      #      limit = 10
      #      grace = "5m"
      #    }
      #  }
      #}

      env {
        CONFIG_PATH   = "/opt/config/confg"
        METADATA_PATH = "/opt/config/metadata"
      }

      volume_mount {
        volume      = "storage"
        destination = "/opt/config"
      }

      resources {
        cpu    = 300
        memory = 500
      }
    }
  }
}
