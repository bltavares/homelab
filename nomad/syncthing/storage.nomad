id = "syncthing-storage"
name = "syncthing-storage"
type = "csi"
plugin_id = "nas"

capacity_max = "4TB"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

parameters {
    uid = "1000"
    gid = "1000"
    mode = "770"
}
