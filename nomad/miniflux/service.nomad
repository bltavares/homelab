job "miniflux" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
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
DATABASE_URL=postgres://miniflux:{{key "miniflux/postgres-password"}}@{{ .Address }}:{{ .Port }}/miniflux?sslmode=disable
{{ else }}
DATABASE_URL={{ key "fake_key_to_await_db" }}
{{ end }}

TRUSTED_REVERSE_PROXY_NETWORKS={{key "authProxy/network_range"}}
EOH
        destination = "secrets/postgres-addr"
        env         = true
      }

      env {
        RUN_MIGRATIONS    = "1"
        AUTH_PROXY_HEADER = "X-Forwarded-User"
        BASE_URL          = "https://miniflux.bltavares.com"
      }

      service {
        name = "miniflux"
        port = "web"

        tags = [
          "gateway.enable=true",
        ]

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
  }

  group "db" {

    network {
      port "db" { to = 5432 }
    }

    volume "persistence" {
      type            = "csi"
      source          = "linstor-miniflux"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "db" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/postgres:18"
        ports = ["db"]
        init  = true
      }

      kill_signal = "SIGTERM"

      volume_mount {
        volume      = "persistence"
        destination = "/var/lib/postgresql"
      }

      service {
        name = "miniflux-db"
        port = "db"
        tags = ["traefik.enable=false"]

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

      resources {
        cpu    = 300
        memory = 800
      }
    }
  }
}
