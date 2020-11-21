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

kickstart.context "Networking"
kickstart.info "Install dependencies"
kickstart.package.install avahi-daemon
kickstart.package.install libnss-mdns
kickstart.package.install mosh
