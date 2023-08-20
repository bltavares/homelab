job "miniflux" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
    }

    service {
      name = "miniflux"
      port = "web"
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }


    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/miniflux/miniflux:latest"
        ports = ["web"]
      }

      template {
        data        = <<EOH
{{ range service "miniflux-db" }}
DATABASE_URL=postgres://miniflux:${file("../../secrets/miniflux/postgres-passwd")}@{{ .Address }}:{{ .Port }}/miniflux?sslmode=disable
{{ end }}
EOH
        destination = "secrets/postgres-addr"
        env         = true
      }

      env {
        RUN_MIGRATIONS    = "1"
        CREATE_ADMIN      = "1"
        ADMIN_USERNAME    = "bltavares"
        ADMIN_PASSWORD    = file("../../secrets/miniflux/admin-passwd")
        AUTH_PROXY_HEADER = "X-Forwarded-User"
        BASE_URL          = "http://miniflux.lab.bltavares.com"
      }

      service {
        check {
          name     = "Service Check"
          type     = "script"
          command  = "/usr/bin/miniflux"
          args     = ["-healthcheck", "auto"]
          interval = "1m"
          timeout  = "30s"

          check_restart {
            limit = 10
            grace = "5m"
          }
        }

        //   check {
        //     name      = "startup check"
        //     type      = "tcp"
        //     port      = "web"
        //     interval  = "10s"
        //     timeout   = "30s"
        //     on_update = "ignore_warnings"
        //   }
      }

      // restart {
      //   attempts = 5
      //   delay    = "1m"
      //   interval = "10m"
      //   mode     = "fail"
      // }

      resources {
        cpu    = 200
        memory = 500
      }
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--token", file("../../secrets/miniflux/tunnel.token"),
          "--url", "${NOMAD_ADDR_web}",
          "miniflux",
        ]
      }

      resources {
        cpu    = 10
        memory = 20
      }
    }
  }

  group "db" {
    network {
      port "db" { to = 5432 }
    }

    service {
      name = "miniflux-db"
      port = "db"
    }

    volume "storage" {
      type            = "csi"
      source          = "miniflux"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    update {
      max_parallel = 0
    }

    task "db" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/bltavares/postgres"
        ports = ["db"]
      }

      kill_signal = "SIGTERM"

      volume_mount {
        volume      = "storage"
        destination = "/var/lib/postgresql/data"
      }

      service {
        check {
          name      = "Postgres Check"
          type      = "script"
          command   = "/usr/bin/pg_isready"
          args      = ["-U", "miniflux"]
          interval  = "1m"
          timeout   = "30s"
          on_update = "ignore_warnings"
        }

        check {
          name     = "Postgres liveness check"
          type     = "script"
          command  = "/usr/bin/pg_isready"
          args     = ["-U", "miniflux"]
          interval = "2m"
          timeout  = "30s"

          check_restart {
            limit = 10
            grace = "15m"
          }
        }
      }

      template {
        data        = file("../../secrets/miniflux/postgres-passwd")
        destination = "secrets/postgres-passwd"
      }

      env {
        POSTGRES_USER          = "miniflux"
        POSTGRES_PASSWORD_FILE = "${NOMAD_SECRETS_DIR}/postgres-passwd"
      }

      resources {
        cpu    = 300
        memory = 800
      }
    }
  }
}