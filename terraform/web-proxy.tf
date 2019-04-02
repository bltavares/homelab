provider "local" {
  version = "~> 1.2"
}

resource "local_file" "lab-config" {
  filename = "../kickstart/files/lab-traefik.toml"
  content = templatefile("templates/lab-traefik.toml.tmpl", {
    radarr       = element(tolist(zerotier_member.archiver.ipv4_assignments), 0),
    sonarr       = element(tolist(zerotier_member.archiver.ipv4_assignments), 0),
    transmission = element(tolist(zerotier_member.archiver.ipv4_assignments), 0),
  })
}
