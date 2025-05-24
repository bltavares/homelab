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
    }

    volume "storage" {
      type            = "csi"
      source          = "calibre"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/linuxserver/calibre-web:latest"
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
        DOCKER_MODS = "linuxserver/mods:universal-calibre"
        PUID        = "1000"
        GUID        = "1000"
      }

      volume_mount {
        volume      = "storage"
        destination = "/config"
      }

      resources {
        cpu    = 300
        memory = 500
      }
    }
  }
}
