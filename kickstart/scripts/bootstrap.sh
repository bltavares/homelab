#!/bin/bash
set -ueo pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}/../../secrets/env.sh"

## PVE
#kickstart deploy root@"192.168.15.32" ssh-keys connection <<<"$NETWORK_ID"
#kickstart deploy root@"192.168.15.3" bootstrap-debian ssh-keys
#kickstart deploy --sudo bltavares@"192.168.15.3" docker-ce monitoring consul-server <../secrets/consul.key
#kickstart deploy --sudo bltavares@192.168.15.3 lab-web
#kickstart deploy --sudo bltavares@192.168.15.2 mediacenter

kickstart deploy --sudo bltavares@archiver.zerotier.bltavares.com nomad-server <../secrets/nomad.key
kickstart deploy --sudo bltavares@pve.zerotier.bltavares.com nomad-server <../secrets/nomad.key
kickstart deploy --sudo bltavares@controller.zerotier.bltavares.com nomad-server <../secrets/nomad.key

# kickstart deploy --sudo bltavares@192.168.15.193 nomad-client
# kickstart deploy --sudo bltavares@"192.168.15.159" nomad-client
# kickstart deploy --sudo bltavares@"192.168.15.160" nomad-client
# kickstart deploy --sudo bltavares@"192.168.15.163" nomad-client
# kickstart deploy --sudo bltavares@"192.168.15.162" nomad-client

# PVE: Debian vm
#kickstart deploy root@192.168.15.193 bootstrap-debian ssh-keys
#kickstart deploy --sudo bltavares@192.168.15.193 docker-ce connection <<<"$NETWORK_ID"
#kickstart deploy --sudo bltavares@192.168.15.193 consul-client <../secrets/consul.key
#kickstart deploy --sudo bltavares@192.168.15.193 lab-web

## Controller
#kickstart deploy --sudo bltavares@"192.168.15.245" consul-client <../secrets/consul.key

## Pi Zeros
# P1
#kickstart deploy --sudo bltavares@"192.168.15.159" consul-client <../secrets/consul.key

# P2
#kickstart deploy --sudo bltavares@"192.168.15.160" consul-client <../secrets/consul.key

# P3
#kickstart deploy --sudo bltavares@192.168.15.163 ssh-keys connection <<<"$NETWORK_ID"
#kickstart deploy --sudo bltavares@"192.168.15.163" consul-client <../secrets/consul.key

# P4
#kickstart deploy --sudo bltavares@192.168.15.162 ssh-keys connection <<<"$NETWORK_ID"
#kickstart deploy --sudo bltavares@"192.168.15.162" consul-client <../secrets/consul.key

#Archiver
#kickstart deploy root@"192.168.15.2" bootstrap-debian ssh-keys
#kickstart deploy --sudo bltavares@"192.168.15.10" docker-ce connection <<<"$NETWORK_ID"
#kickstart deploy --sudo bltavares@"192.168.15.10" fileserver mediacenter
#kickstart deploy --sudo bltavares@"192.168.15.2" monitoring mediacenter

# LibreElec
#kickstart deploy --sudo bltavares@"192.168.15.2" consul-server <../secrets/consul.key
