job "october" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { static = 3493 }
    }

    service {
      name = "october"
      port = "web"
    }

    task "image" {
      driver = "docker"

      config {
        image = "bltavares/october"
        ports = ["web"]
        network_mode = "host"
        args = ["-a", "${NOMAD_TASK_DIR}/addresses.csv"]
      }

      template {
        data = file("./addresses.csv")
        destination = "local/addresses.csv"
      }

      resources {
        cpu = 100
        memory = 10
      }

    }
  }
}