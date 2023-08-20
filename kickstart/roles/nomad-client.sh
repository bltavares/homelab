#!/bin/bash

kickstart.context "Nomad: Client"

source recipes/install-nomad.sh

arch="$(uname -m)" kickstart.file.template files/nomad-client.tmpl.hcl >/etc/nomad.d/client.hcl
if [[ -f files/nomad/"$(hostname)".hcl ]]; then
    cp files/nomad/"$(hostname)".hcl /etc/nomad.d
fi

kickstart.service.enable nomad
kickstart.service.restart nomad
