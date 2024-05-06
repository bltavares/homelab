job "images-sync" {
  type = "batch"

  periodic {
    crons            = ["@weekly"]
    prohibit_overlap = true
  }

  task "sync" {
    driver = "docker"

    config {
      image      = "quay.io/skopeo/stable:latest"
      entrypoint = ["/bin/bash"]
      args       = ["local/copy.sh"]
    }

    template {
      data = <<EOH
# skopeo copy docker://gcr.io/radicle-services/radicle-httpd docker://registry.lab.bltavares.com/radicle-services/radicle-httpd
# skopeo copy docker://gcr.io/radicle-services/radicle-httpd docker://registry.lab.bltavares.com/radicle-services/radicle-node

function scopy() { 
  echo "Sync: $1"
  skopeo copy docker://$1 docker://registry.lab.bltavares.com/$1
}

scopy bltavares/october
scopy bltavares/postgres
scopy elasticdog/tiddlywiki
scopy linuxserver/jackett
scopy linuxserver/radarr
scopy linuxserver/sonarr
scopy miniflux/miniflux:latest
scopy vaultwarden/server
scopy bltavares/home-consule:0.1.0
scopy cloudflare/cloudflared:latest
scopy gitea/gitea
scopy linuxserver/transmission
scopy matrixconduit/matrix-conduit:next
scopy girlbossceo/conduwuit:latest
scopy nginx:latest
scopy actualbudget/actual-server:latest-alpine
EOH

      destination = "local/copy.sh"
    }
  }
}
