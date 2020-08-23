#!/bin/bash

set -e
kickstart.context "Minecraft Bedrock Server"

if ! kickstart.command_exists godns; then
(
     cd /tmp
     wget -O godns.tar.gz https://github.com/TimothyYe/godns/releases/download/V2.3/godns-linux64-2.3.tar.gz
     tar xvf godns.tar.gz
     mv godns /usr/local/bin/godns
)
fi

cp files/godns.service /lib/systemd/system/godns.service
cp files/secrets/minecraft/godns.json /etc/godns.json
kickstart.service.enable godns
kickstart.service.start godns

cp files/godns6.service /lib/systemd/system/godns6.service
cp files/secrets/minecraft/godns6.json /etc/godns6.json
cp files/godns.service /lib/systemd/system/godns.service
cp files/secrets/minecraft/godns.json /etc/godns.json
kickstart.service.enable godns6
kickstart.service.start godns6

docker pull itzg/minecraft-bedrock-server
docker rm -f minecraft || true
docker run -d -ti --name minecraft \
 -e EULA=TRUE \
 -e ALLOW_CHEATS=true \
 -e LEVEL_NAME="Familia Corrosiva" \
 -e WHITE_LIST=true \
 -v /opt/minecraft:/data \
 --network host \
 itzg/minecraft-bedrock-server
docker system prune -f
