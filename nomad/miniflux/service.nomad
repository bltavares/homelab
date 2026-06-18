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
        destination = "secrets/postgres-addr"
        env         = true
        data        = <<-INI
{{ range service "miniflux-db" }}
DATABASE_URL="postgres://miniflux:{{key "miniflux/postgres-password"}}@{{ .Address }}:{{ .Port }}/miniflux?sslmode=disable"
{{ else }}
DATABASE_URL="{{ key "fake_key_to_await_db" }}"
{{ end }}

TRUSTED_REVERSE_PROXY_NETWORKS="{{key "authProxy/network_range"}}"

RUN_MIGRATIONS="1"
# Allow access to split-horizon linkding on private ip
INTEGRATION_ALLOW_PRIVATE_NETWORKS=1
BASE_URL="https://miniflux.bltavares.com"

OAUTH2_PROVIDER=oidc
OAUTH2_OIDC_DISCOVERY_ENDPOINT="https://id.bltavares.com/auth/v1/"
OAUTH2_CLIENT_ID="miniflux"
OAUTH2_CLIENT_SECRET="{{ key "miniflux/oidc_secret" }}"
OAUTH2_REDIRECT_URL="https://miniflux.bltavares.com/oauth2/oidc/callback"
DISABLE_LOCAL_AUTH=true
INI
      }

      service {
        name = "miniflux"
        port = "web"

        tags = [
          "gateway.enable=true",
          "oidc",
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
