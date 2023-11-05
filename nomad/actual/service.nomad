job "actual" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 5006 }
    }

    service {
      name = "actual"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "actual"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image      = "registry.lab.bltavares.com/actualbudget/actual-server:latest-alpine"
        force_pull = true
        ports      = ["web"]
      }

      # service {
      #  check {
      #    name     = "Service Check"
      #    type     = "http"
      #    path     = "/_actual/client/versions"
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

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }

  }
}
