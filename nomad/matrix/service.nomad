job "matrix" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    meta {
      domain = "matrix.bltavares.com"
    }

    network {
      port "conduit" { to = 6167 }
      port "web" { to = 80 }
    }

    service {
      name = "matrix"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "matrix"
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
        image      = "registry.lab.bltavares.com/matrixconduit/matrix-conduit:next"
        force_pull = true
        ports      = ["conduit"]
        init       = true
      }

      service {
        check {
          name     = "Service Check"
          type     = "http"
          path     = "/_matrix/client/versions"
          port     = "conduit"
          interval = "10s"
          timeout  = "30s"

          check_restart {
            limit = 10
            grace = "5m"
          }
        }
      }

      env {
        CONDUIT_SERVER_NAME      = "${NOMAD_META_domain}"
        CONDUIT_DATABASE_PATH    = "/var/lib/matrix-conduit/"
        CONDUIT_DATABASE_BACKEND = "rocksdb"
        CONDUIT_PORT             = "${NOMAD_PORT_conduit}"
        // CONDUIT_MAX_REQUEST_SIZE   = "20_000_000" # in bytes, ~20 MB
        CONDUIT_ALLOW_REGISTRATION = "false"
        CONDUIT_ALLOW_FEDERATION   = "true"
        CONDUIT_TRUSTED_SERVERS    = "[\"matrix.org\"]"
        #CONDUIT_MAX_CONCURRENT_REQUESTS: 100
        CONDUIT_LOG     = "warn,rocket=off,_=off,sled=off"
        CONDUIT_ADDRESS = "0.0.0.0"
        CONDUIT_CONFIG  = "" # Ignore file lookups and use env vars
      }


      volume_mount {
        volume      = "storage"
        destination = "/var/lib/matrix-conduit"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }

    task "well-known" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/nginx:latest"
        ports = ["web"]
        mount {
          type   = "bind"
          source = "local/well-known.conf"
          target = "/etc/nginx/conf.d/matrix.conf"
        }
      }


      template {
        data        = file("./well-known.conf")
        destination = "local/well-known.conf"
      }

      resources {
        cpu    = 10
        memory = 20
      }
    }

    task "ingress" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
        args = [
          "tunnel", "--no-autoupdate",
          "run",
          "--url", "${NOMAD_ADDR_web}",
          "matrix",
        ]
      }

      template {
        data        = <<EOH
TUNNEL_TOKEN="{{key "cloudflare/tunnel/matrix"}}"
EOH
        destination = "secrets/token.env"
        env         = true
      }

      resources {
        cpu    = 20
        memory = 50
      }
    }
  }
}
