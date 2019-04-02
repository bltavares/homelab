#!/bin/bash

kickstart.context "Monitoring"

mkdir -p /etc/netdata
cp files/netdata/* /etc/netdata/

docker pull netdata/netdata
docker rm -f netdata
docker run -d --name=netdata \
    --net=host \
    -p 19999:19999 \
    -v /proc:/host/proc:ro \
    -v /sys:/host/sys:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /etc/hostname:/etc/hostname:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/netdata/netdata.conf:/etc/netdata/netdata.conf:ro \
    -v /etc/netdata/charts.d.conf:/etc/netdata/charts.d.conf:ro \
    -l SERVICE_NAME="$(hostname)-netdata" \
    -l SERVICE_TAGS="traefik.frontends.lab-status-$(hostname).rule=Host:$(hostname).status.lab.bltavares.com,traefik.frontends.cloud-status-$(hostname).rule=Host:$(hostname).status.cloud.bltavares.com" \
    -e PGID="$(grep docker /etc/group | cut -d ':' -f 3)" \
    --cap-add SYS_PTRACE \
    --security-opt apparmor=unconfined \
    --restart=unless-stopped netdata/netdata
docker image prune -fa
