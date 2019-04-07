#!/bin/bash

kickstart.context "Nomad: Server"

read -r NOMAD_KEY
source recipes/install-nomad.sh

nomad_key="$NOMAD_KEY" kickstart.file.template files/nomad-server.tmpl.hcl >/etc/nomad.d/server.hcl

kickstart.service.enable nomad
kickstart.service.restart nomad

curl -X PUT -v -d '{"name": "nomad-server", "port": 4646}' -H 'Content-Type: application/json' localhost:8500/v1/agent/service/register
