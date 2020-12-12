#!/usr/bin/env bash

set -e
kickstart.context "Setup Prometheus"

mkdir -p /opt/prometheus
cp files/prometheus.yml /opt/prometheus/prometheus.yml

docker volume create prometheus

docker pull prom/prometheus
docker rm -f prometheus || true
docker run --name=prometheus \
  --network=host \
  -v /opt/prometheus:/etc/prometheus \
  -v prometheus:/prometheus \
  -p 9090:9090 \
  --restart=unless-stopped -d \
  prom/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/usr/share/prometheus/console_libraries \
  --web.console.templates=/usr/share/prometheus/consoles \
  --storage.tsdb.retention.size=200MB

docker image prune -fa
