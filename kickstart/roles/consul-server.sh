#!/bin/bash

kickstart.context "Consul Server"
read -r CONSUL_KEY

docker pull consul
docker rm -f consul
docker volume create consul
docker run --name consul \
    --net=host \
    -p 8500:8500 \
    -l SERVICE_NAME="consul-server" \
    -v consul:/consul/data \
    -d --restart=unless-stopped \
    consul agent -server \
    -encrypt "$CONSUL_KEY" \
    -bind '{{ GetPrivateInterfaces | include "network" "fc36:152b:7a00::/40" | attr "address"}}' \
    -client '127.0.0.1 172.17.0.1 {{range $i, $e := GetPrivateInterfaces }}{{if eq $e.MTU 2800 }}{{if $i}} {{end}}{{attr "address" $e}}{{end}}{{end}}' \
    -retry-join "vaporware.zerotier.bltavares.com" \
    -retry-join "archiver.zerotier.bltavares.com" \
    -retry-join "libreelec.zerotier.bltavares.com" \
    -retry-join "pve.zerotier.bltavares.com" \
    -ui

docker pull gliderlabs/registrator:latest
docker rm -f registrator
docker run \
    --name=registrator \
    --net=host \
    -d --restart=unless-stopped \
    --volume=/etc/hostname:/etc/hostname:ro \
    --volume=/var/run/docker.sock:/tmp/docker.sock:ro \
    gliderlabs/registrator:latest \
    consul://localhost:8500

docker system prune -f
