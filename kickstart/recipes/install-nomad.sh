#!/bin/bash
nomad_version=0.9.0

arch="$(uname -m)"

case "$arch" in
armv6*)
    url=https://github.com/bltavares/nomad-arm6l/releases/download/v${nomad_version}-armv6l/nomad-armv6l.zip
    ;;
armv7*)
    url=https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_arm.zip
    ;;
x86_64)
    url=https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip
    ;;
*)
    url=https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_arm64.zip
    ;;
esac

kickstart.info "Fetching Nomad..."
kickstart.info "Arch: ${arch} - url: ${url}"
(
    cd /tmp
    rm -f nomad.zip
    curl -sLo nomad.zip $url

    kickstart.info "Installing Nomad..."

    kickstart.package.install unzip
    rm -f nomad
    unzip nomad.zip >/dev/null
    chmod +x nomad
    mv nomad /usr/local/bin/nomad

    # Setup Nomad
    mkdir -p /opt/nomad
    mkdir -p /etc/nomad.d

    tee /etc/systemd/system/nomad.service >/dev/null <<"EOF"
[Unit]
Description = "Nomad"
After=network-online.target
After=docker.service

[Install]
WantedBy=network-online.target

[Service]
# Stop consul will not mark node as failed but left
KillSignal=INT
ExecStart=/usr/local/bin/nomad agent -config="/etc/nomad.d"
Restart=always
ExecStopPost=/bin/sleep 5
EOF
)

kickstart.info "Setup env var for nomad cli"
cp files/nomad.sh /etc/profile.d/nomad.sh
