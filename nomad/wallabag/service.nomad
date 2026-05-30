job "wallabag" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 80 }
      port "redis" { to = 6379 }
    }

    service {
      name = "wallabag"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "wallabag"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "redis" {
      driver = "docker"

      config {
        image    = "redis:latest"
        ports    = ["redis"]
        work_dir = "/opt/data/redis"
      }

      volume_mount {
        volume      = "storage"
        destination = "/opt/data"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }

    task "service" {
      driver = "docker"
      config {
        image = "wallabag/wallabag:latest"
        ports = ["web"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/var/www/wallabag/data"
      }

      env {
        SYMFONY__ENV__DOMAIN_NAME = "https://wallabag.lab.bltavares.com"
      }

      resources {
        cpu    = 200
        memory = 500
      }

      template {
        data = <<EOH
SYMFONY__ENV__REDIS_HOST={{env "NOMAD_IP_redis"}}
SYMFONY__ENV__REDIS_PORT={{env "NOMAD_HOST_PORT_redis"}}
EOH

        destination = "secrets/dynamic-addrs.env"
        env         = true
      }


    }

    task "importer" {
      driver = "docker"
      config {
        image = "wallabag/wallabag:latest"
        args  = ["import", "pocket"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/var/www/wallabag/data"
      }

      env {
        SYMFONY__ENV__DOMAIN_NAME = "https://wallabag.lab.bltavares.com"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      template {
        data = <<EOH
SYMFONY__ENV__REDIS_HOST={{env "NOMAD_IP_redis"}}
SYMFONY__ENV__REDIS_PORT={{env "NOMAD_HOST_PORT_redis"}}
PHP_MEMORY_LIMIT=1G
EOH

        destination = "secrets/dynamic-addrs.env"
        env         = true
      }


    }

    #   task "ingress" {
    #     driver = "docker"

    #     config {
    #       image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
    #       args = [
    #         "tunnel", "--no-autoupdate",
    #         "run",
    #         "--token", file("../../secrets/wallabag/tunnel.token"),
    #         "--url", "${NOMAD_ADDR_web}",
    #         "wallabag",
    #       ]
    #     }

    #     resources {
    #       cpu    = 50
    #       memory = 50
    #     }
    #   }

    # }

  }
}