job "paperless" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8000 }
    }

    service {
      name = "paperless"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "paperless"
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
        image = "registry.lab.bltavares.com/paperless-ngx/paperless-ngx:latest"
        ports = ["web"]

        # Allow download of OCR packages
        dns_servers = ["8.8.8.8"]
      }

      env {
        # Change Dirs to match Nomad's lack of subdir volume mount
        PAPERLESS_CONSUMPTION_DIR = "/opt/data/paperless/consumption/"
        PAPERLESS_DATA_DIR        = "/opt/data/paperless/data/"
        PAPERLESS_EMPTY_TRASH_DIR = "/opt/data/paperless/empty_trash/"
        PAPERLESS_MEDIA_ROOT      = "/opt/data/paperless/media/"
        PAPERLESS_STATICDIR       = "/opt/data/paperless/static/"

        # Configs
        PAPERLESS_TIKA_ENABLED       = "true"
        PAPERLESS_URL                = "https://paperless.lab.bltavares.com"
        PAPERLESS_USE_X_FORWARD_HOST = "true"

        PAPERLESS_OCR_LANGUAGE       = "eng+por" # languages to use for OCR
        PAPERLESS_OCR_LANGUAGES      = "por"     # languages to install additionally to the default
        PAPERLESS_PRE_CONSUME_SCRIPT = "${NOMAD_TASK_DIR}/removepasswords.py"
        REMOVE_PDF_PASSWORDS         = "${NOMAD_SECRETS_DIR}/pdf-password-list.txt"
      }

      template {
        data        = <<EOH
{{ range service "paperless-redis" }}
PAPERLESS_REDIS=redis://{{ .Address }}:{{ .Port }}
{{ end }}
{{ range service "paperless-gotenberg" }}
PAPERLESS_TIKA_GOTENBERG_ENDPOINT=http://{{ .Address }}:{{ .Port }}
{{ end }}
{{ range service "paperless-tika" }}
PAPERLESS_TIKA_ENDPOINT=http://{{ .Address }}:{{ .Port }}
{{ end }}

PAPERLESS_GMAIL_OAUTH_CLIENT_ID="{{ key "paperless/gmail/client-id" }}"
PAPERLESS_GMAIL_OAUTH_CLIENT_SECRET="{{ key "paperless/gmail/client-secret" }}"
EOH
        destination = "secrets/dynamic-addrs.env"
        env         = true
      }

      template {
        data        = file("./removepasswords.py")
        destination = "local/removepasswords.py"
        perms       = "755"
      }

      template {
        data        = <<EOH
{{ key "paperless/pdf-password-list" }}
EOH
        destination = "secrets/pdf-password-list.txt"
      }

      # service {
      #   check {
      #     name     = "alive"
      #     type     = "http"
      #     path     = "/livez"
      #     port     = "web"
      #     interval = "5m"
      #     timeout  = "10s"
      #   }

      #   check_restart {
      #     limit           = 3
      #     grace           = "90s"
      #     ignore_warnings = false
      #   }
      # }

      volume_mount {
        volume      = "storage"
        destination = "/opt/data"
      }

      resources {
        cpu    = 1500
        memory = 1500
      }
    }

    # task "ingress" {
    #   driver = "docker"
    #   config {
    #     image = "registry.lab.bltavares.com/cloudflare/cloudflared:latest"
    #     args = [
    #       "tunnel", "--no-autoupdate",
    #       "run",
    #       "--token", file("../../secrets/activitypub/tunnel.token"),
    #       "--url", "${NOMAD_ADDR_web}",
    #       "paperless",
    #     ]
    #   }

    #   resources {
    #     cpu    = 50
    #     memory = 50
    #   }
    # }
  }

  group "redis" {
    network {
      port "redis" { to = 6379 }
    }

    service {
      name = "paperless-redis"
      port = "redis"
    }


    volume "storage" {
      type            = "csi"
      source          = "paperless"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }


    task "redis" {
      driver = "docker"

      config {
        image    = "registry.lab.bltavares.com/redis:latest"
        ports    = ["redis"]
        work_dir = "/opt/data/redis"
      }

      volume_mount {
        volume      = "storage"
        destination = "/opt/data"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }

  group "converters" {
    service {
      name = "paperless-gotenberg"
      port = "gotenberg"
    }

    service {
      name = "paperless-tika"
      port = "tika"
    }

    network {
      port "gotenberg" { to = 3000 }
      port "tika" { to = 9998 }
    }

    task "gotenberg" {
      driver = "docker"
      config {
        image      = "registry.lab.bltavares.com/gotenberg/gotenberg:8.7"
        force_pull = true
        ports      = ["gotenberg"]
        command    = "gotenberg"
        args = [
          "--chromium-disable-javascript=true",
          "--chromium-allow-list=file:///tmp/.*",
        ]
      }

      resources {
        cpu    = 500
        memory = 500
      }
    }

    task "tika" {
      driver = "docker"
      config {
        image = "apache/tika:latest"
        ports = ["tika"]
      }

      resources {
        cpu    = 500
        memory = 500
      }
    }
  }
}