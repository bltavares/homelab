job "matrix" {
  type        = "service"
  datacenters = ["dc1"]

  ## TODO preprocessor include?
  affinity {
    attribute = "${node.unique.name}"
    operator  = "set_contains_any"
    value     = "archiver,pve"
    weight    = -100
  }

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
      tags = ["gateway.enable=true"]
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
        // image      = "registry.lab.bltavares.com/matrixconduit/matrix-conduit:next"
        image      = "registry.lab.bltavares.com/continuwuation/continuwuity:latest"
        force_pull = true
        ports      = ["conduit"]
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
        CONDUIT_SERVER_NAME   = "${NOMAD_META_domain}"
        CONDUIT_DATABASE_PATH = "/var/lib/matrix-conduit/"
        CONDUIT_PORT          = "${NOMAD_PORT_conduit}"
        // CONDUIT_MAX_REQUEST_SIZE   = "20_000_000" # in bytes, ~20 MB
        CONDUIT_ALLOW_REGISTRATION = "false"
        CONDUIT_ALLOW_FEDERATION   = "true"
        CONDUIT_TRUSTED_SERVERS    = "[\"matrix.org\"]"
        #CONDUIT_MAX_CONCURRENT_REQUESTS: 100
        CONDUIT_LOG     = "warn,rocket=off,_=off,sled=off"
        CONDUIT_ADDRESS = "0.0.0.0"
        CONDUIT_CONFIG  = "" # Ignore file lookups and use env vars
      }

      template {
        data        = <<-INI
CONDUIT_TURN_URIS=["turn:turn.cloudflare.com:3478?transport=udp","turn:turn.cloudflare.com:3478?transport=tcp","turns:turn.cloudflare.com:5349?transport=tcp"]
CONDUIT_TURN_USERNAME="{{key "conduwuit/turn/username"}}"
CONDUIT_TURN_PASSWORD="{{key "conduwuit/turn/password"}}"
INI
        destination = "secrets/turn.env"
        env         = true
      }


      volume_mount {
        volume      = "storage"
        destination = "/var/lib/matrix-conduit"
      }

      resources {
        cpu    = 300
        memory = 500
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
        destination = "local/well-known.conf"
        data        = <<-NGINX
server {
    server_name {{ env "NOMAD_META_domain" }}
    listen      80 default_server http2;
    proxy_buffering off;

    location /.well-known/matrix/server {
       return 200 '{"m.server": "{{ env "NOMAD_META_domain" }}:443"}';
       types { } default_type "application/json; charset=utf-8";
    }

   location /.well-known/matrix/client {
       return 200 '{"m.homeserver": {"base_url": "https://{{ env "NOMAD_META_domain" }}"}, "org.matrix.msc3575.proxy": {"url": "https://{{ env "NOMAD_META_domain" }}"}}';
       types { } default_type "application/json; charset=utf-8";
       add_header "Access-Control-Allow-Origin" *;
   }

   location / {
        proxy_set_header Host $host;
        proxy_pass http://{{ env "NOMAD_ADDR_conduit" }};
   }
}
NGINX
      }

      resources {
        cpu    = 10
        memory = 20
      }
    }
  }
}
