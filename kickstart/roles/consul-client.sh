#!/bin/bash

kickstart.context "Consul Client"
read -r CONSUL_KEY

docker volume create consul
docker pull consul
docker rm -f consul
docker run --name consul \
    --net=host \
    -v consul:/consul/data \
    -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
    -d --restart=unless-stopped \
    consul agent \
    -dns-port=53 \
    -recursor=1.1.1.1 \
    -recursor=1.0.0.1 \
    -encrypt "$CONSUL_KEY" \
    -bind '{{ GetPrivateInterfaces | include "network" "fc36:152b:7a00::/40" | attr "address"}}' \
    -client '127.0.0.1 172.17.0.1 {{range $i, $e := GetPrivateInterfaces }}{{if eq $e.MTU 2800 }}{{if $i}} {{end}}{{attr "address" $e}}{{end}}{{end}}' \
    -retry-join "vaporware.zerotier.bltavares.com" \
    -retry-join "archiver.zerotier.bltavares.com" \
    -retry-join "tiny.zerotier.bltavares.com" \
    -retry-join "pve.zerotier.bltavares.com"

address_6plane="$(ip addr show zt5u44ufvb | grep fc | awk '{print $2}' | cut -d/ -f1)/80"
cat >/etc/docker/daemon.json <<<"
{
    \"ipv6\": true,
    \"fixed-cidr-v6\": \"$address_6plane\"
}
"
kickstart.service.restart docker

docker pull gliderlabs/registrator:latest
docker rm -f registrator
docker run \
    --name=registrator \
    --net=host \
    -d --restart=unless-stopped \
    -e 'GL_DISABLE_VERSION_CHECK=true' \
    --volume=/etc/hostname:/etc/hostname:ro \
    --volume=/var/run/docker.sock:/tmp/docker.sock:ro \
    gliderlabs/registrator:latest \
    consul://localhost:8500

docker system prune -f
