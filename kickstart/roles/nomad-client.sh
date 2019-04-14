#!/bin/bash

kickstart.context "Nomad: Client"

source recipes/install-nomad.sh

arch="$(uname -m)" kickstart.file.template files/nomad-client.tmpl.hcl >/etc/nomad.d/client.hcl

kickstart.service.enable nomad
kickstart.service.restart nomad
