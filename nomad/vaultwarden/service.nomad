job "vaultwarden" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 80 }
    }

    service {
      name = "pass"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "vaultwarden"
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
        image = "registry.lab.bltavares.com/vaultwarden/server"
        ports = ["web"]
        init  = true
      }

      volume_mount {
        volume      = "storage"
        destination = "/data"
      }

      service {
        check {
          name     = "Service Check"
          type     = "http"
          path     = "/alive"
          port     = "web"
          interval = "30s"
          timeout  = "30s"
        }

        check_restart {
          limit           = 3
          grace           = "90s"
          ignore_warnings = false
        }
      }

      env {
        SIGNUPS_ALLOWED = false

        ## For U2F to work, the server must use HTTPS
        DOMAIN = "https://pass.lab.bltavares.com"

      }
      user = "1000:1000"

      template {
        data        = <<EOH
#  https://bitwarden.com/host
PUSH_ENABLED=true
PUSH_INSTALLATION_ID={{ key "vaultwarden/bitwarden/id" }}
PUSH_INSTALLATION_KEY={{ key "vaultwarden/bitwarden/key" }}

## You can generate it here: https://upgrade.yubico.com/getapikey/
YUBICO_CLIENT_ID={{ key "vaultwarden/bitwarden/id" }}
YUBICO_SECRET_KEY="{{ key "vaultwarden/bitwarden/key" }}"
EOH
        destination = "secrets/env.sh"
        env         = true
      }
    }
  }
}