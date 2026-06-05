name = "traefik-gateway"
type = "host"
plugin_id = "mkdir"
node = "citadel"

capacity_max = "1G"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

parameters {
    uid = "1000"
    gid = "1000"
    mode = "770"
}
