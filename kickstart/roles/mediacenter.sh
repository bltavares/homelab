#!/usr/bin/env bash

DOWNLOADS=/media/twotb
MOVIES=/media/twotb/Filmes
SERIES=/media/twotb/Seriados
SYNCTHING_SHARE=/media/onetb/Syncthing
CONFIG_FOLDER=/opt/config
TZ=America/Sao_Paulo
REPO=linuxserver

mkdir -p "$CONFIG_FOLDER"

docker pull $REPO/syncthing
docker rm -f syncthing
docker run --name=syncthing \
    -e PGID=0 -e PUID=0 -e UMASK_SET=000 \
    -e TZ \
    -v "${CONFIG_FOLDER}/syncthing/:/config" \
    -v "${SYNCTHING_SHARE}/:/data1" \
    --network=host \
    -p 8384:8384 \
    --restart=unless-stopped -d \
    $REPO/syncthing

docker pull $REPO/transmission
docker rm -f transmission
docker run --name=transmission \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -v /storage/transmission:/config \
    -v "${DOWNLOADS}/:/downloads" \
    -v "${DOWNLOADS}/watch:/watch" \
    --net=host \
    -p 9091:9091 \
    -l SERVICE_TAGS="traefik.enable=false" \
    --restart=unless-stopped -d \
    $REPO/transmission

docker pull $REPO/sonnar
docker rm -f sonarr
docker run --name sonarr \
    -e PUID=0 -e PGID=0 \
    -e TZ \
    -v "${CONFIG_FOLDER}/sonarr/:/config" \
    -v "${SERIES}/:/tv" \
    -v "${DOWNLOADS}:/downloads" \
    --net=host \
    -p 8989:8989 \
    -l SERVICE_TAGS="traefik.enable=false" \
    --restart=unless-stopped -d \
    $REPO/sonarr

docker pull $REPO/jackett
docker rm -f jackett
docker run --name=jackett \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -v "${CONFIG_FOLDER}/jackett/:/config" \
    -v "${DOWNLOADS}/:/downloads" \
    --net=host \
    -p 9117:9117 \
    --restart=unless-stopped -d \
    $REPO/jackett

docker pull $REPO/radarr
docker rm -f radarr
docker run --name=radarr \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -v "${CONFIG_FOLDER}/radarr/:/config" \
    -v "${DOWNLOADS}/:/downloads" \
    -v "${MOVIES}/:/movies" \
    --net=host \
    -p 7878:7878 \
    -l SERVICE_TAGS="traefik.enable=false" \
    --restart=unless-stopped -d \
    $REPO/radarr

# docker pull $REPO/bazarr
# docker rm -f bazarr
# docker run --name=bazarr \
#     -e PGID=0 -e PUID=0 \
#     -e TZ \
#     -v "${CONFIG_FOLDER}/bazarr/:/config" \
#     -v "${MOVIES}/:/movies" \
#     -v "${SERIES}/:/tv" \
#     --net=host \
#     --restart=unless-stopped -d \
#     $REPO/bazarr

docker image prune -f
