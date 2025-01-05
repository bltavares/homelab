#!/bin/bash

set -e
kickstart.context "Minecraft Java/Bedrock Server"

# Tunnel for gaming as Cloudflare only supports https
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
sudo apt update
sudo apt install playit

## TODO add [besta-fera](https://github.com/bltavares/besta-fera) setup

docker pull itzg/mc-proxy:java21
docker rm -f velocity || true
docker run -d -ti --name velocity \
  -e TYPE=VELOCITY \
  -e ONLINE_MODE=TRUE \
  -e SERVER_PORT="25565" \
  -v /opt/velocity:/server \
  --restart=unless-stopped \
  --network host \
  itzg/mc-proxy:java21

docker pull itzg/minecraft-server:java21

docker rm -f creative || true
docker run -d -ti --name creative \
  -e TYPE=PAPER \
  -e PAPER="1.21.3" \
  -e ONLINE_MODE=FALSE \
  -e EULA=TRUE \
  -e ENABLE_AUTOPAUSE=TRUE \
  -e JVM_DD_OPTS="disable.watchdog=true" \
  -e MAX_TICK_TIME="-1" \
  -v /opt/creative:/data \
  --restart=unless-stopped \
  -p "25511:25565" \
  itzg/minecraft-server:java21

docker rm -f oneblock || true
docker run -d -ti --name oneblock \
  -e TYPE=PAPER \
  -e PAPER="1.21.3" \
  -e ONLINE_MODE=FALSE \
  -e EULA=TRUE \
  -e ENABLE_AUTOSTOP=TRUE \
  --restart=on-failure \
  -v /opt/oneblock:/data \
  -p "25512:25565" \
  itzg/minecraft-server:java21

docker rm -f skyblock || true
docker run -d -ti --name skyblock \
  -e TYPE=PAPER \
  -e PAPER="1.21.3" \
  -e ONLINE_MODE=FALSE \
  -e EULA=TRUE \
  -e ENABLE_AUTOSTOP=TRUE \
  --restart=on-failure \
  -v /opt/skyblock:/data \
  -p "25513:25565" \
  itzg/minecraft-server:java21

docker rm -f survival || true
docker run -d -ti --name survival \
  -e TYPE=PAPER \
  -e PAPER="1.21.3" \
  -e ONLINE_MODE=FALSE \
  -e EULA=TRUE \
  -e ENABLE_AUTOSTOP=TRUE \
  --restart=on-failure \
  -v /opt/survival:/data \
  -p "25514:25565" \
  itzg/minecraft-server:java21

docker system prune -f
