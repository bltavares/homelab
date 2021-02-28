#!/bin/bash

set -e
kickstart.context "Minecraft Java/Bedrock Server"

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

# cp files/godns6.service /lib/systemd/system/godns6.service
# cp files/secrets/minecraft/godns6.json /etc/godns6.json
# kickstart.service.enable godns6
# kickstart.service.start godns6

docker pull bltavares/minecraft
docker rm -f minecraft || true
docker run -d -ti --name minecraft \
  -e EULA=TRUE \
  -e SERVER_NAME="Familia Corrosiva" \
  -e MOTD="Venha se divertir" \
  -e DIFFICULTY=peaceful \
  -e MODE=creative \
  -e WHITELIST="bltavares,*bltavares" \
  -e OPS="bltavares,*bltavares" \
  -v /opt/minecraft:/data \
  --restart=unless-stopped \
  --network host \
  bltavares/minecraft
docker system prune -f
