job "ipfs" {
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
      port "swarm" { to = 4001 } # TCP/UDP
      port "admin" { to = 5001 }
    }

    service {
      name = "ipfs-gateway"
      port = "web"
    }

    service {
      name = "ipfs"
      port = "admin"
    }

    volume "storage" {
      type            = "csi"
      source          = "kubo"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "image" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/ipfs/kubo"
        ports = ["web", "swarm", "admin"]
      }

      volume_mount {
        volume      = "storage"
        destination = "/data/ipfs"
      }

      env {
        IPFS_PROFILE = "lowpower"
      }

      resources {
        cpu    = 3500
        memory = 300
      }
    }
  }
}