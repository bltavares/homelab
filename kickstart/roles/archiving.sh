#!/bin/bash
## TODO https://hub.docker.com/r/valeriansaliou/sonic
kickstart.context "Setup Archivebox"

STORAGE=/mnt/meli/archivebox

docker pull archivebox/archivebox
docker rm -f archivebox || true
docker run --name archivebox \
    -v $STORAGE:/data \
    -e ALLOWED_HOSTS="*" \
    -e MEDIA_MAX_SIZE="50m" \
    -p 8000:8000 \
    -l SERVICE_NAME=archivebox \
    -d --restart unless-stopped \
    archivebox/archivebox server --quick-init 0.0.0.0:8000
