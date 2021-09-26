#!/bin/bash

set -e
kickstart.context "Gitea"

source recipes/nfs.sh

nfs-ensure-exists /services/gitea
mount="$(nfs-mount-path gitea /data /services/gitea)"

docker pull gitea/gitea:1.15.3
docker rm -f gitea || true
docker run --name gitea \
	-l SERVICE_NAME="gitea" \
    -p 3000:3000 \
    -p 4222:22 \
    -l SERVICE_3000_NAME=gitea \
    -l SERVICE_22_IGNORE=true \
    --mount "${mount}" \
    -e USER_GID="$nfs_user" \
    -e GROUP_GID="$nfs_user" \
    --restart=unless-stopped -d \
	gitea/gitea:1.15.3 \


docker system prune -f
