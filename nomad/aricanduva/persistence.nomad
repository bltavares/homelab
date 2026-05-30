id   = "linstor-aricanduva"
name = "linstor-aricanduva"

type      = "csi"
plugin_id = "linstor.csi.linbit.com"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

mount_options {
  fs_type = "xfs"
}
