job "bookmarks" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 9090 }
    }

    service {
      name = "bookmarks"
      port = "web"

      tags = [
        "gateway.enable=true",
      ]
    }

    volume "storage" {
      type            = "csi"
      source          = "bookmarks"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/sissbruecker/linkding:latest"
        # image = "ghcr.io/sissbruecker/linkding:latest"
        ports = ["web"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/etc/linkding/data"
      }

      template {
        destination = "secrets/config.env"
        env         = true
        data        = <<-ini
LD_DISABLE_LOGIN_FORM=True
LD_ENABLE_OIDC=True
OIDC_OP_AUTHORIZATION_ENDPOINT=https://id.bltavares.com/auth/v1/oidc/authorize
OIDC_OP_TOKEN_ENDPOINT=https://id.bltavares.com/auth/v1/oidc/token
OIDC_OP_USER_ENDPOINT=https://id.bltavares.com/auth/v1/oidc/userinfo
OIDC_OP_JWKS_ENDPOINT=https://id.bltavares.com/auth/v1/oidc/certs
OIDC_RP_CLIENT_ID=linkding
OIDC_RP_CLIENT_SECRET="{{ key "linkding/oidc_secret" }}"
OIDC_USERNAME_CLAIM=preferred_username
ini

      }

      resources {
        cpu    = 200
        memory = 500
      }
    }
  }

}
