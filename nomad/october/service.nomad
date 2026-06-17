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
romulus,C8:FF:BF:04:04:6A
rotterdam,84:47:09:65:1E:9C
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
