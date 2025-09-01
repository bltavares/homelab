job "registry" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "ryzen"
  }


  group "service" {
    network {
      port "web" { to = 8000 }
    }

    service {
      name = "registry"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "trow"
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
        image = "ghcr.io/trow-registry/trow:0.9.0"
        ports = ["web"]
        args = [
          "-d", "/data",
          "-n", "registry.lab.bltavares.com",
          "--config-file", "local/proxies.yaml",
        ]
      }

      service {
        check {
          name     = "alive"
          type     = "http"
          path     = "/healthz"
          port     = "web"
          interval = "30s"
          timeout  = "2s"
        }
      }

      env {
        RUST_LOG = "info"
      }

      user = "1000:1000"

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      template {
        data        = <<EOF
registry_proxies:
  registries:
    - alias: docker
      host: registry-1.docker.io
EOF
        destination = "local/proxies.yaml"

      }

      resources {
        cpu    = 300
        memory = 512
      }
    }
  }
}
