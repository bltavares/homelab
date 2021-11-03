job "storage-node" {
  datacenters = ["dc1"]
  type        = "system"

  group "node" {
    task "node" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.3.0"

        args = [
          "--type=node",
          "--node-id=${attr.unique.hostname}",
          "--nfs-server=omv.zerotier.bltavares.com:/meli/services",
          "--mount-options=rw,nfsvers=4,async",
        ]

        network_mode = "host" # required so the mount works even after stopping the container
        privileged   = true
      }

      csi_plugin {
        id        = "nfs"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
