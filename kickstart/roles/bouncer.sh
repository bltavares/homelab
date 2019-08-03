#!/bin/bash

set -e
kickstart.context "Setup Bouncer"

docker pull bltavares/znc
docker rm -f znc || true
docker run --name znc \
  -p 6997:6997 \
  --network=host \
  -v /media/onetb/znc:/znc \
  -d --restart unless-stopped \
  -l SERVICE_TAGS="traefik.protocol=https" \
  bltavares/znc

cp files/certificates/archiver.zerotier.bltavares.com.cert /media/onetb/znc/znc.pem
cat files/certificates/archiver.zerotier.bltavares.com.key >>/media/onetb/znc/znc.pem
