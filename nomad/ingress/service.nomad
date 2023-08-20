job "ingress" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "citadel"
  }

  group "service" {
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "admin" {}
      port "ssb-shs" {
        static = 8008
      }
    }

    service {
      name = "gateway"
      port = "admin"
    }

    task "service" {
      driver = "docker"
      config {
        image        = "traefik:latest"
        ports        = ["admin", "http", "https", "ssb-shs"]
        network_mode = "host"
        mount {
          type   = "bind"
          source = "local"
          target = "/etc/traefik"
        }
      }

      template {
        data        = file("./config.toml.tpl")
        destination = "local/traefik.toml"
      }

      template {
        data        = file("./ssb.toml.tpl")
        destination = "local/dynamic/ssb.toml"
        change_mode = "noop"
      }

      resources {
        cpu    = 10
        memory = 80
      }
    }
  }
}