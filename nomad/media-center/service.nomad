locals {
  CONFIG_FOLDER = "/opt/config"
  DOWNLOADS     = "/media/twotb"
  MOVIES        = "/media/twotb/Filmes"
  SERIES        = "/media/twotb/Seriados"
  AUDIOBOOKS    = "/media/twotb/Audiobooks"
  PODCASTS      = "/media/twotb/Podcasts"
  TZ            = "America/Sao_Paulo"
}


job "media-center" {
  type        = "service"
  datacenters = ["dc1"]


  constraint {
    attribute = "${node.unique.name}"
    value     = "archiver"
  }

  group "service" {
    network {
      port "transmission" { static = 9091 }
      port "sonarr" { static = 8989 }
      port "radarr" { static = 7878 }
      port "jackett" { static = 9117 }
      port "audiobooks" { to = 80 }
    }

    task "transmission" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/linuxserver/transmission"

        ports        = ["transmission"]
        network_mode = "host"

        volumes = [
          "/storage/transmission:/config",
          "${local.DOWNLOADS}/:/downloads",
          "${local.DOWNLOADS}/watch:/watch",
        ]
      }

      env {
        PGID = 0
        PUID = 0
        TZ   = "${local.TZ}"
      }
    }

    task "sonarr" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/linuxserver/sonarr"

        ports        = ["sonarr"]
        network_mode = "host"

        volumes = [
          "${local.CONFIG_FOLDER}/sonarr/:/config",
          "${local.SERIES}/:/tv",
          "${local.DOWNLOADS}:/downloads",
        ]
      }

      env {
        PGID = 0
        PUID = 0
        TZ   = "${local.TZ}"
      }
    }

    task "radarr" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/linuxserver/radarr"

        ports        = ["radarr"]
        network_mode = "host"

        volumes = [
          "${local.CONFIG_FOLDER}/radarr/:/config",
          "${local.MOVIES}/:/movies",
          "${local.DOWNLOADS}:/downloads",
        ]
      }

      env {
        PGID = 0
        PUID = 0
        TZ   = "${local.TZ}"
      }
    }

    task "jackett" {
      driver = "docker"

      config {
        image = "registry.lab.bltavares.com/linuxserver/jackett"

        ports        = ["jackett"]
        network_mode = "host"

        volumes = [
          "${local.CONFIG_FOLDER}/jackett/:/config",
          "${local.DOWNLOADS}/:/downloads",
        ]
      }

      env {
        PGID = 0
        PUID = 0
        TZ   = "${local.TZ}"
      }
    }

    service {
      name = "audiobooks"
      port = "audiobooks"
    }

    task "audiobookshelf" {
      driver = "docker"

      config {
        # image = "ghcr.io/advplyr/audiobookshelf:latest"
        image = "registry.lab.bltavares.com/advplyr/audiobookshelf:latest"
        ports = ["audiobooks"]

        volumes = [
          "${local.CONFIG_FOLDER}/audiobookshelf/config/:/config",
          "${local.CONFIG_FOLDER}/audiobookshelf/metadata/:/metadata",
          "${local.AUDIOBOOKS}/:/audiobooks",
          "${local.PODCASTS}/:/podcasts",
        ]
      }

      env {
        TZ = "${local.TZ}"
      }
    }
  }
}