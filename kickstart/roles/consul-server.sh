#!/bin/bash

kickstart.context "Consul Server"
read -r CONSUL_KEY

docker pull hashicorp/consul
docker rm -f consul
docker volume create consul
docker run --name consul \
    --net=host \
    -p 8500:8500 \
    -l SERVICE_NAME="consul-server" \
    -v consul:/consul/data \
    -d --restart=unless-stopped \
    hashicorp/consul agent -server \
    -encrypt "$CONSUL_KEY" \
    -bind '{{ GetPrivateInterfaces | include "network" "fc36:152b:7a00::/40" | attr "address"}}' \
    -client '127.0.0.1 172.17.0.1 {{range $i, $e := GetPrivateInterfaces }}{{if eq $e.MTU 2800 }}{{if $i}} {{end}}{{attr "address" $e}}{{end}}{{end}}' \
    -retry-join "citadel.zerotier.bltavares.com" \
    -retry-join "tiny.zerotier.bltavares.com" \
    -retry-join "ryzen.zerotier.bltavares.com" \
    -ui

docker system prune -f
