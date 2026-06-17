job "calibre" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${meta.arch_base}"
    value     = "amd64"
  }

  affinity {
    attribute = "${node.unique.name}"
    operator  = "set_contains_any"
    value     = "archiver,pve"
    weight    = -100
  }

  group "service" {
    network {
      port "web" { to = 8083 }
    }

    service {
      name = "calibre"
      port = "web"
      tags = [
        "oidc",
      ]
    }

    volume "config" {
      type            = "csi"
      source          = "calibre"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    volume "storage" {
      type            = "csi"
      source          = "calibre-books"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/crocodilestick/calibre-web-automated:latest"
        ports = ["web"]
      }

      # service {
      #  check {
      #    name     = "Service Check"
      #    type     = "http"
      #    path     = "/_calibre/client/versions"
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
        PUID               = "1000"
        GUID               = "1000"
        NETWORK_SHARE_MODE = true
      }

      volume_mount {
        volume      = "config"
        destination = "/config"
      }

      volume_mount {
        volume      = "storage"
        destination = "/calibre-library"
      }

      resources {
        cpu    = 300
        memory = 500
      }
    }
  }
}
