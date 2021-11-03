id        = "home-consule"
name      = "home-consule"
type      = "csi"
plugin_id = "nfs"

capacity_max = "1G"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

parameters {
  uid  = "1000"
  gid  = "1000"
  mode = "770"
}
