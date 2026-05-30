job "linstor-csi" {
  datacenters = ["dc1"]
  type        = "system"

  group "csi" {
    task "csi-plugin" {

      driver = "docker"

      config {
        # registry.lab.bltavares.com/piraeusdatastore/piraeus-csi:latest
        image = "quay.io/piraeusdatastore/piraeus-csi:v1.10.5"

        args = [
          "--csi-endpoint=unix://csi/csi.sock",
          "--node=${attr.unique.hostname}",
          "--log-level=info"
        ]

        privileged = true
      }

      env {
        LS_CONTROLLERS = "romulus.zerotier.bltavares.com:3370,tiny.zerotier.bltavares.com:3370,rotterdam.zerotier.bltavares.com:3370,ryzen.zerotier.bltavares.com:3370"
      }

      csi_plugin {
        id        = "linstor.csi.linbit.com"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 200 # 200MB
      }
    }
  }
}
