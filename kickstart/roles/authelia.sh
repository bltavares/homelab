#!/bin/bash

set -e
kickstart.context "Authelia"

source recipes/nfs.sh

nfs-ensure-exists /services/authelia
mount="$(nfs-mount-path authelia /config /services/authelia)"

docker pull authelia/authelia
docker rm -f authelia || true
docker run --name authelia \
	-l SERVICE_NAME="authelia" \
    -p 9091:9091 \
    --mount "${mount}" \
    --user "$nfs_user:$nfs_user" \
    --restart=unless-stopped -d \
	authelia/authelia

docker system prune -f
