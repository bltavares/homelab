job "whoami" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 80 }
    }
    task "service" {
      driver = "docker"
      config {
        image = "traefik/whoami"
        ports = ["web"]
      }

      service {
        name = "whoami"
        port = "web"
        tags = [
          "sso",
        ]
      }
    }
  }
}
