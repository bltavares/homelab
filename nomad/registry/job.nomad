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
  skopeo copy docker://$1 docker://registry.lab.bltavares.com/$${2:-$1}
}

#scopy actualbudget/actual-server:latest-alpine
scopy alpine:latest
scopy bltavares/aricanduva:latest
scopy bltavares/home-consule:0.1.0
scopy bltavares/october:latest
scopy bltavares/postgres:latest
scopy cloudflare/cloudflared:latest
scopy codeberg.org/forgejo/forgejo:15 forgejo/forgejo:15
scopy elasticdog/tiddlywiki:latest
scopy forgejo.ellis.link/continuwuation/continuwuity:latest continuwuation/continuwuity:latest
scopy ghcr.io/sissbruecker/linkding:latest sissbruecker/linkding:latest
scopy ipfs/kubo:latest
scopy linuxserver/jackett:latest
scopy linuxserver/radarr:latest
scopy linuxserver/sonarr:latest
scopy linuxserver/syncthing:latest
scopy linuxserver/transmission:latest
scopy lscr.io/linuxserver/calibre-web:latest linuxserver/calibre-web:latest
scopy miniflux/miniflux:latest
scopy nginx:latest
scopy sintan1729/chhoto-url:latest
scopy superseriousbusiness/gotosocial:latest
scopy vaultwarden/server:latest
scopy ghcr.io/sebadob/rauthy:latest sebadob/rauthy:latest
EOH

      destination = "local/copy.sh"
    }
  }
}
