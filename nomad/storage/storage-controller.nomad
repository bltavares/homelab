job "storage-controller" {
  datacenters = ["dc1"]
  type        = "service"

  group "controller" {
    task "controller" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.3.0"

        args = [
          "--type=controller",
          "--node-id=${attr.unique.hostname}",
          "--nfs-server=omv.zerotier.bltavares.com:/meli/services",
          "--mount-options=rw,nfsvers=4,async",
        ]

        network_mode = "host" # required so the mount works even after stopping the container
        privileged   = true
      }

      csi_plugin {
        id        = "nfs"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 100
      }
    }
  }
}
