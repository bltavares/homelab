
job "aricanduva" {
  type        = "service"
  datacenters = ["dc1"]


  group "service" {
    network {
      port "web" { to = 3000 }
    }

    volume "persistence" {
      type            = "csi"
      source          = "linstor-aricanduva"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "aricanduva"
      port = "web"
      tags = [
        "gateway.enable=true",
      ]
    }

    task "permission-fix" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "registry.lab.bltavares.com/alpine:latest"
        args  = ["chown", "1000:1000", "/mnt/data"]
      }
      volume_mount {
        volume      = "persistence"
        destination = "/mnt/data"
      }
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/bltavares/aricanduva:latest"
        ports = ["web"]
        init  = true
      }

      env {
        IP_EXTRACTION = "RightmostXForwardedFor"
        RPC_ADDRESS   = "https://ipfs.lab.bltavares.com/api/v0"
        RUST_LOG      = "aricanduva=info"
      }

      template {
        data        = <<EOH
AUTH_ACCESS_KEY={{key "aricanduva/access_key"}}
AUTH_SECRET_KEY={{key "aricanduva/secret_key"}}
EOH
        destination = "secrets/auth.env"
        env         = true
      }

      resources {
        cpu    = 500
        memory = 200
      }

      volume_mount {
        volume      = "persistence"
        destination = "/app"
      }

      service {
        check {
          name     = "alive"
          type     = "http"
          path     = "/healthz"
          port     = "web"
          interval = "1m"
          timeout  = "10s"
        }

        check_restart {
          limit           = 3
          grace           = "90s"
          ignore_warnings = false
        }
      }
    }
  }
}
