#!/usr/bin/env bash

set -e
kickstart.context "Setup grafana"

mkdir -p /opt/grafana
cp files/grafana.ini /opt/grafana/grafana.ini

docker pull grafana/grafana
docker rm -f grafana || true
docker run --name=grafana \
  --user 0 \
  --network=host \
  -p 3000:3000 \
  --volume /opt/grafana:/var/lib/grafana \
  --volume /opt/grafana/grafana.ini:/etc/grafana/grafana.ini \
  --restart=unless-stopped -d \
  grafana/grafana

docker image prune -fa
