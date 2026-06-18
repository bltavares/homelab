job "dns" {
  type        = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.unique.name}"
    value     = "romulus"
  }

  group "service" {
    network {
      port "dns" {
        static = 53
      }
      port "admin" {
        to = 3000
      }
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
        image = "registry.lab.bltavares.com/0xerr0r/blocky"
        ports = ["dns", "admin"]
        args  = ["--config", "${NOMAD_TASK_DIR}"]
      }

      service {
        name = "dns"
        port = "admin"
        tags = [
          "passthru",
        ]

        check {
          name     = "alive"
          type     = "script"
          command  = "/app/blocky"
          args     = ["healthcheck"]
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

      template {
        destination = "local/setup.yaml"
        # TODO: Reload instead of restart
        # https://github.com/0xERR0R/blocky/pull/2022
        data        = <<-YAML
# yaml-language-server: $schema=https://raw.githubusercontent.com/0xERR0R/blocky/main/docs/config.schema.json
upstreams:
  groups:
    default:
       # cloudflare
       ## 1.1.1.1
       ## 2606:4700:4700::1111
       ## h3/quic
       - https://cloudflare-dns.com/dns-query
       # google
       ## 8.8.8.8
       ## 2001:4860:4860::8888
       ## h3/quic
       - https://dns.google/dns-query
       # quad9
       ## 9.9.9.9
       ## 2620:fe::9
       # no h3/quic
       - https://dns.quad9.net/dns-query
       # adguard
       - quic://unfiltered.adguard-dns.com
       ## https://unfiltered.adguard-dns.com/dns-query
       # controld
       - quic://p0.freedns.controld.com
blocking:
  denylists:
    ads:
    # HaGeZi's Pro Blocklist
    - https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt
  clientGroupsBlock:
    default:
      - ads
customDNS:
  zone: |
    $ORIGIN bltavares.com.
    {{- range services }}
    {{- if .Tags | contains "gateway.enable=true" }}
    {{ .Name }} 3600 CNAME romulus.zerotier
    {{- end }}
    {{- end }}
ports:
  dns: 53
  http: 3000
YAML
      }
    }
  }
}
