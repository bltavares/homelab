#!/bin/bash

kickstart.context "Nomad: Server"

read -r NOMAD_KEY
source recipes/install-nomad.sh

arch="$(uname -m)" nomad_key="$NOMAD_KEY" kickstart.file.template files/nomad-server.tmpl.hcl >/etc/nomad.d/server.hcl

kickstart.service.enable nomad
kickstart.service.restart nomad

curl -X PUT -v -d '{"name": "nomad-server", "port": 4646}' -H 'Content-Type: application/json' localhost:8500/v1/agent/service/register

# Docker based agent
# docker volume create nomad
# docker run \
#     -d --restart unless-stopped \
#     --net host \
#     -v $(pwd)/nomad.hcl:/etc/nomad.d/config.hcl \
#     -v nomad:/opt/nomad \
#     bltavares/nomad
