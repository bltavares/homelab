job "vault" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8200 }
      port "telemetry" { to = 8125 }
    }

    service {
      name = "vault"
      port = "web"
    }

    service {
      name = "vault-telemetry"
      port = "telemetry"
    }


    task "image" {
      driver = "docker"

      config {
        image   = "vault:1.8.5"
        ports   = ["web", "telemetry"]
        cap_add = ["ipc_lock"]
        args    = ["server"]
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