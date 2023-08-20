plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}

client {
  reserved {
    cpu    = 1000
    memory = 3072
  }
}