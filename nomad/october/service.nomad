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
    }

    task "image" {
      driver = "docker"

      config {
        image        = "bltavares/october"
        network_mode = "host"
        args = [
          "-a", "${NOMAD_TASK_DIR}/addresses.csv",
          "--listen", "0.0.0.0:${NOMAD_PORT_web}",
        ]
      }

      template {
        data        = file("./addresses.csv")
        destination = "local/addresses.csv"
      }

      resources {
        cpu    = 100
        memory = 10
        disk   = 1
      }

    }
  }
}