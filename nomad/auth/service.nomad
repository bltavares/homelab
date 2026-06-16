job "auth" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "http" {
        to = "8080"
      }
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    service {
      name = "id"
      port = "http"
      tags = [
        "gateway.enable=true",
      ]
    }

    volume "persistence" {
      type            = "csi"
      source          = "linstor-auth"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "permission-fix" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image = "registry.lab.bltavares.com/alpine:latest"
        args  = ["chown", "10001:10001", "/mnt/data"]
      }
      volume_mount {
        volume      = "persistence"
        destination = "/mnt/data"
      }
    }

    task "service" {
      driver = "docker"
      config {
        image = "registry.lab.bltavares.com/sebadob/rauthy:latest"
        ports = ["http"]
        args  = ["serve", "-c", "${NOMAD_TASK_DIR}/config.toml"]
      }

      env {
      }

      template {
        destination = "local/config.toml"
        data        = <<-TOML
[cluster]
node_id = 1

[server]
listen_scheme = "http"
pub_url = "id.bltavares.com"
proxy_mode = true
trusted_proxies = {{ key "authProxy/network_range" | split "," | toTOML }}

[webauthn]
rp_id = "id.bltavares.com"
rp_origin = "https://id.bltavares.com:443"
rp_name = "homelab"

[access]
admin_button_hide = true

#[matrix]
#msc3861_enable = true
TOML
      }

      template {
        destination = "secrets/config.env"
        env         = true
        data        = <<-INI
ENC_KEYS="{{key "auth/enc_keys"}}"
{{ range $index, $key := key "auth/enc_keys" | split "\n" }}
  {{ if eq $index 0 }}
ENC_KEY_ACTIVE="{{ index ($key | split "/") 0 }}"
  {{ end }}
{{ end }}

HQL_SECRET_RAFT="{{ key "auth/raft_secret" }}"
HQL_SECRET_API="{{ key "auth/api_secret" }}"
INI
      }

      service {
        check {
          name     = "alive"
          type     = "http"
          port     = "http"
          path     = "/health"
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
        volume      = "persistence"
        destination = "/app/data"
      }

      resources {
        cpu    = 300
        memory = 180
      }
    }
  }
}
