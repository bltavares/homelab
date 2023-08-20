job "nas-storage-controller" {
  datacenters = ["dc1"]
  type        = "service"

  group "controller" {
    task "controller" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.6.1"

        args = [
          "--type=controller",
          "--node-id=${attr.unique.hostname}",
          "--nfs-server=omv.zerotier.bltavares.com:/nas/nomad",
          "--mount-options=rw,vers=4.2,async,relatime,timeo=600,rsize=1048576,wsize=1048576,retrans=2,hard,fsc",
        ]

        network_mode = "host" # required so the mount works even after stopping the container
        privileged   = true
      }

      csi_plugin {
        id        = "nas"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }
  }
}
