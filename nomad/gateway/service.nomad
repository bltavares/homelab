job "gateway" {
  type        = "service"
  datacenters = ["oracle"]

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
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    service {
      name = "gateway-traefik"
      port = "admin"
    }

    volume "storage" {
      type            = "host"
      source          = "traefik-gateway"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "service" {
      driver = "docker"
      config {
        image        = "public.ecr.aws/docker/library/traefik:latest"
        ports        = ["admin", "http", "https"]
        network_mode = "host"
        mount {
          type   = "bind"
          source = "local"
          target = "/etc/traefik"
        }
      }

      service {
        check {
          name     = "alive"
          type     = "tcp"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }


      restart {
        attempts = 10
        delay    = "10s"
        interval = "30s"
        mode     = "delay"
      }

      volume_mount {
        volume      = "storage"
        destination = "/storage"
      }

      template {
        data        = file("./config/static.toml.tpl")
        destination = "local/traefik.toml"
      }

      template {
        data        = <<EOH
CF_DNS_API_TOKEN={{ key "acme/cloudflare/token" }}
EOH
        destination = "secrets/env.sh"
        env         = true
      }

      resources {
        cpu    = 1000
        memory = 80
      }
    }

  }
}
