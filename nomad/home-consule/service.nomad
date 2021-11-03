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
      access_mode     = "multi-node-multi-writer"
    }

    task "image" {
      driver = "docker"
      config {
        image = "bltavares/home-consule:0.1.0"
        ports = ["web"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/app"
      }

      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
    }
  }
}