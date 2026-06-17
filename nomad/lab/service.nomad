job "lab" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "romulus"
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

      port "git" {
        static = 222
      }
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    volume "storage" {
      type            = "csi"
      source          = "traefik-lab"
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
        name = "traefik-lab"
        port = "admin"

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
        destination = "local/traefik.toml"
        data        = <<-TOML
# [log]
# level = "DEBUG"
#
# [accessLog]
# format = "json"

[entrypoints.traefik]
 address = "{{ env "NOMAD_ADDR_admin" }}"

[api]
dashboard = true
insecure = true

[entryPoints.web]
address = ":80"

[entryPoints.web.http.redirections.entryPoint]
to = "ssl"
scheme = "https"

[entryPoints.ssl]
address = ":443"
http3 = {}
asDefault = true
[entryPoints.ssl.http.tls]
certResolver = "letsencrypt"
[[entryPoints.ssl.http.tls.domains]]
main = "bltavares.com"
sans = ["*.lab.bltavares.com", "*.bltavares.com"]

[entryPoints.git]
address = ":222"

[certificatesResolvers.letsencrypt.acme]
email = "{{ key "acme/email" }}"
storage = "/storage/acme.json"
[certificatesResolvers.letsencrypt.acme.dnsChallenge]
provider = "cloudflare"

[providers.file]
directory = "/etc/traefik/dynamic"

[providers.consulCatalog]
defaultRule = "Host(`{{"{{ normalize .Name }}"}}.lab.bltavares.com`) || Host(`{{"{{ normalize .Name }}"}}.bltavares.com`)"
endpoint = { address = "localhost:8500" }
TOML
      }

      template {
        destination = "local/dynamic/mediacenter.toml"
        change_mode = "noop"
        data        = <<-TOML
[http.routers.radarr]
rule = "Host(`radarr.lab.bltavares.com`)"
service = "radarr"
[[http.services.radarr.loadBalancer.servers]]
url = "http://10.147.17.110:7878"

[http.routers.sonarr]
rule = "Host(`sonarr.lab.bltavares.com`)"
service = "sonarr"
[[http.services.sonarr.loadBalancer.servers]]
url = "http://10.147.17.110:8989"

[http.routers.transmission]
rule = "Host(`transmission.lab.bltavares.com`)"
service = "transmission"
[[http.services.transmission.loadBalancer.servers]]
url = "http://10.147.17.110:9091"
TOML
      }

      template {
        destination = "local/dynamic/nodes.toml"
        change_mode = "noop"
        data        = <<-TOML
[http.routers.proxmox]
rule = "Host(`proxmox.lab.bltavares.com`)"
service = "proxmox"
[http.services.proxmox.loadBalancer]
serversTransport = "insecureHttps"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.2:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.3:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.4:8006"
[[http.services.proxmox.loadBalancer.servers]]
url = "https://192.168.15.6:8006"

[http.routers.omv]
rule = "Host(`omv.lab.bltavares.com`)"
service = "omv"
[http.services.omv.loadBalancer]
serversTransport = "insecureHttps"
[[http.services.omv.loadBalancer.servers]]
url = "https://omv.zerotier.bltavares.com:443"
[http.serversTransports.insecureHttps]
insecureSkipVerify = true
TOML
      }

      template {
        destination = "local/dynamic/sso.toml"
        change_mode = "noop"
        data        = <<-TOML
{{- range service "id" -}}
{{- scratch.Set "auth" (printf "http://%s:%d" .Address .Port) -}}
{{- end -}}
{{- range $services := services}}
{{- if .Tags | contains "sso"}}

[http.middlewares.{{.Name}}-sso.forwardAuth]
address = "{{ scratch.Get "auth" }}/auth/v1/clients/{{.Name}}/forward_auth?redirect_state=302"
[http.routers.{{ .Name }}]
rule = "Host(`{{ .Name }}.lab.bltavares.com`) || Host(`{{ .Name }}.bltavares.com`)"
middlewares = ["{{ .Name }}-sso@file"]
service = "{{ .Name }}@consulcatalog"
priority = 100
[http.routers.{{ .Name }}-sso]
rule = "(Host(`{{ .Name }}.lab.bltavares.com`) || Host(`{{ .Name }}.bltavares.com`)) && Path(`/auth/v1/clients/{{.Name}}/forward_auth/callback`)"
service = "id@consulcatalog"
priority = 101
{{- else if .Tags | containsAny ("[oidc,passthru]" | parseYAML) | not }}

# {{.Name}}: {{.Tags}}
[http.routers.{{ .Name }}-disable]
rule = "Host(`{{ .Name }}.lab.bltavares.com`) || Host(`{{ .Name }}.bltavares.com`)"
service = "noop@internal"
priority = 1000
{{- end}}
{{- end}}
TOML
      }

      template {
        destination = "secrets/env.sh"
        env         = true
        data        = <<-INI
CF_DNS_API_TOKEN={{ key "acme/cloudflare/token" }}
INI
      }

      resources {
        cpu    = 1000
        memory = 80
      }
    }
  }
}
