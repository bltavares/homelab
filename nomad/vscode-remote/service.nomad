job "vscode-remote" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${node.unique.name}"
    value     = "ryzen"
  }

  group "service" {
    task "service" {
      driver = "exec"

      artifact {
        source = "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64"

        options {
          archive = "tar.gz"
        }
      }

      config {
        command = "code"
        args    = ["--", "--accept-server-license-terms"]

        pid_mode = "host"
        ipc_mode = "host"
      }
    }
  }
}