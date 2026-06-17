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
      port "web" { static = 8080 }
      port "swarm" { static = 4001 } # TCP/UDP
      port "admin" { static = 5001 }
    }

    service {
      name = "ipfs-gateway"
      port = "web"
      tags = [
        "passthru",
      ]

    }

    service {
      name = "ipfs"
      port = "admin"
      tags = [
        "passthru",
      ]
    }

    volume "storage" {
      type            = "csi"
      source          = "linstor-ipfs"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "service" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/ipfs/kubo"
        args = [
          # default
          "daemon", "--migrate=true", "--agent-version-suffix=docker",
          # add
          "--enable-gc"
        ]
        ports        = ["web", "swarm", "admin"]
        network_mode = "host"
        volumes = [
          "alloc/container-init.d:/container-init.d"
        ]
      }

      volume_mount {
        volume      = "storage"
        destination = "/data/ipfs"
      }

      template {
        data        = <<EOD
#!/bin/sh
set -ex
ipfs config Addresses.API /ip4/$NOMAD_IP_admin/tcp/5001
ipfs config Addresses.Gateway /ip4/$NOMAD_IP_web/tcp/8080
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["https://ipfs.lab.bltavares.com", "https://ipfs-geateway.lab.bltavares.com", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["GET", "PUT", "POST", "HEAD"]'
EOD
        destination = "alloc/container-init.d/configure-private-ips.sh"
        perms       = "755"
      }

      resources {
        cpu    = 3500
        memory = 900
      }
    }
  }
}
