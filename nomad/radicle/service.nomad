job "radicle" {
  type        = "service"
  datacenters = ["dc1"]

  group "service" {

    affinity {
      attribute = "${attr.cpu.numcores}"
      operator  = ">"
      value     = "2"
      weight    = 100
    }

    reschedule {
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "120s"
      unlimited      = true
    }

    network {
      port "web" { to = 8080 }
      port "radicle" { to = 8776 }
    }


    service {
      name = "radicle"
      port = "web"
    }

    volume "storage" {
      type            = "csi"
      source          = "radicle"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "radicle" {
      driver = "docker"

      config {
        image   = "registry.lab.bltavares.com/radicle-services/radicle-node"
        ports   = ["radicle"]
        command = ["init"]
        init    = true
      }

      volume_mount {
        volume      = "storage"
        destination = "/root/"
      }

      env {
        // TODO consul key
        RAD_PASSPHRASE = "seed"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }

    task "httpd" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/radicle-services/radicle-httpd"
        ports = ["web"]
        init  = true
      }

      volume_mount {
        volume      = "storage"
        destination = "/root/"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }
  }
}