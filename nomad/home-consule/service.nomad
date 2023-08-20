job "home" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {

    network {
      port "web" { to = 3000 }
    }

    service {
      name = "home"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "home-consule"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "image" {
      driver = "docker"
      config {
        image = "registry.lab.bltavares.com/bltavares/home-consule:0.1.0"
        ports = ["web"]
      }

      service {
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          port     = "web"
          interval = "10s"
          timeout  = "2s"
        }

        check_restart {
          limit           = 3
          grace           = "90s"
          ignore_warnings = false
        }
      }

      volume_mount {
        volume      = "storage"
        destination = "/app"
      }

      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }

      resources {
        cpu    = 10
        memory = 10
      }
    }
  }
}