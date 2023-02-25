job "miniflux" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
      port "db" { to = 5432 }
    }

    service {
      name = "miniflux"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "miniflux"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "miniflux/miniflux:latest"
        ports = ["web"]
      }

      env {
        DATABASE_URL      = "postgres://miniflux:${file("../../secrets/miniflux/postgres-passwd")}@${NOMAD_ADDR_db}/miniflux?sslmode=disable"
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
          interval = "10s"
          timeout  = "30s"
        }
      }

    }

    task "db" {
      driver = "docker"

      config {
        image = "postgres:15"
        ports = ["db"]
      }

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
          interval  = "10s"
          timeout   = "30s"
          on_update = "ignore_warnings"
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
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--token", file("../../secrets/miniflux/tunnel.token"),
          "--url", "${NOMAD_ADDR_web}",
          "miniflux",
        ]
      }
    }
  }
}