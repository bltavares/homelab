job "october" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" {}
    }

    service {
      name = "october"
      port = "web"
      tags = [
        "sso",
      ]
    }

    task "image" {
      driver = "docker"

      config {
        image        = "registry.lab.bltavares.com/bltavares/october"
        network_mode = "host"
        args = [
          "-a", "${NOMAD_TASK_DIR}/addresses.csv",
          "--listen", "0.0.0.0:${NOMAD_PORT_web}",
        ]
      }

      template {
        destination = "local/addresses.csv"
        data        = <<-CSV
tiny,64:1c:67:6b:9d:10
omv,a0:b3:cc:e2:58:aa
ryzen,84:47:09:1D:D3:E4
romulus,84:47:09:83:02:62
rotterdam,84:47:09:65:1E:9C
synthcore,30:56:0F:03:D4:A0
CSV
      }

      resources {
        cpu    = 10
        memory = 10
        disk   = 1
      }

    }
  }
}
