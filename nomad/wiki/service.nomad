job "wiki" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {
    network {
      port "web" { to = 8080 }
    }

    service {
      name = "wiki"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "tiddlywiki"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }
    update {
      max_parallel = 0
    }

    task "image" {
      driver = "docker"

      config {
        image   = "registry.lab.bltavares.com/elasticdog/tiddlywiki"
        command = "wiki"
        args    = ["--listen", "host=0.0.0.0"]
        ports   = ["web"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/tiddlywiki"
      }

      user = "1000:1000"

      resources {
        cpu    = 10
        memory = 150
      }
    }
  }
}