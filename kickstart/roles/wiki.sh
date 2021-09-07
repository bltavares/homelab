#!/bin/bash

set -e
kickstart.context "Wiki (Tiddlywiki)"

STORAGE="/media/onetb"

docker pull elasticdog/tiddlywiki

wrapper() {
    docker rm -f tiddlywiki || true

    docker run --name tiddlywiki \
	-l SERVICE_NAME="tiddlywiki" \
    -p 8080:8080 \
	-v "${STORAGE}/tiddlywiki":/tiddlywiki \
	--user "$(id -u):$(id -g)" \
    --restart=unless-stopped -d \
	elasticdog/tiddlywiki \
    wiki \
    "$@"
}

wrapper --init server || true
wrapper --listen host=0.0.0.0

docker system prune -f
