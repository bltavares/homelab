#!/bin/bash
kickstart.context "Web Proxy: Lab side"

mkdir -p /etc/traefik/
cp files/lab-traefik.toml /etc/traefik/traefik.toml
cp files/certificates/lab.bltavares.com.cert /etc/traefik/traefik.crt
cp files/certificates/lab.bltavares.com.key /etc/traefik/traefik.key

docker pull traefik
docker rm -f traefik
docker run --name traefik \
    -d --restart unless-stopped \
    --net host \
    -p 8080:8080 \
    -p 80:80 \
    -l SERVICE_8080_NAME="lab-traefik" \
    -l SERVICE_80_NAME=proxy \
    -l SERVICE_80_TAGS="traefik.enable=false" \
    -v /etc/traefik:/etc/traefik:ro \
    traefik
docker system prune -f
