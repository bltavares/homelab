#!/bin/bash

set -e
kickstart.context "ZeroTier"

kickstart.info "Reading networkid"
read -r NETWORK_ID

if [[ -z "$NETWORK_ID" ]]; then
  kickstart.info "NETWORK ID not provided"
  exit 1
fi

kickstart.info "Starting ZeroTier"

docker pull bltavares/zerotier
docker rm -f zerotier || true
docker run --device=/dev/net/tun \
  --net=host \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_ADMIN \
  --cap-add=CAP_SYS_RAWIO \
  -v /var/lib/zerotier-one:/var/lib/zerotier-one \
  --restart unless-stopped \
  --name zerotier \
  -d bltavares/zerotier

sleep 1

kickstart.info "Joining network"
docker exec zerotier zerotier-cli join "$NETWORK_ID"

kickstart.context "Docker networking"
kickstart.package.install moreutils
kickstart.package.install jq
address_6plane="$(ip addr show zt5u44ufvb | grep fc | awk '{print $2}' | cut -d/ -f1)/80"
jq  '. * input' /etc/docker/daemon.json <(cat <<EOF
{
    "ipv6": true,
    "fixed-cidr-v6": "$address_6plane",
    "experimental": true,
    "ip6tables": true
}
EOF
) | sponge /etc/docker/daemon.json

kickstart.service.restart docker

kickstart.info "Setting up docker networking fixes"
cp files/docker-networking@.service /etc/systemd/system/docker-networking@.service
systemctl daemon-reload
systemctl enable docker-networking@zt5u44ufvb.service --now

kickstart.context "Networking"
kickstart.info "Install dependencies"

if kickstart.os.is Suse; then
  kickstart.package.install avahi
  kickstart.package.install nss-mdns
else 
  kickstart.package.install avahi-daemon
  kickstart.package.install libnss-mdns
fi
kickstart.package.install mosh
