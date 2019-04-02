#!/bin/bash
kickstart.context "Web Proxy: Lab side"

cp files/lab-traefik.toml /etc/traefik.toml

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
    -v /etc/traefik.toml:/etc/traefik/traefik.toml \
    traefik
docker system prune -f
