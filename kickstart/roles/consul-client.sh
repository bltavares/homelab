#!/bin/bash

kickstart.context "Consul Client"
read -r CONSUL_KEY

docker volume create consul
docker pull hashicorp/consul
docker rm -f consul
docker run --name consul \
    --net=host \
    -v consul:/consul/data \
    -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
    -d --restart=unless-stopped \
    hashicorp/consul agent \
    -dns-port=53 \
    -recursor=1.1.1.1 \
    -recursor=1.0.0.1 \
    -encrypt "$CONSUL_KEY" \
    -bind '{{ GetPrivateInterfaces | include "network" "fc36:152b:7a00::/40" | attr "address"}}' \
    -client '127.0.0.1 172.17.0.1 {{range $i, $e := GetPrivateInterfaces }}{{if eq $e.MTU 2800 }}{{if $i}} {{end}}{{attr "address" $e}}{{end}}{{end}}' \
    -retry-join "citadel.zerotier.bltavares.com" \
    -retry-join "archiver.zerotier.bltavares.com" \
    -retry-join "tiny.zerotier.bltavares.com" \
    -retry-join "pve.zerotier.bltavares.com"

docker system prune -f
