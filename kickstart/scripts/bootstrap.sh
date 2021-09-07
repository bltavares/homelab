#!/bin/bash
set -ueo pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}/../../secrets/env.sh"

archiver="192.168.15.2"
pve="192.168.15.3"
tiny="192.168.15.4"
omv="192.168.15.5"
debian_pve="192.168.15.193"

## Bootstrap
false && for server in $archiver $pve $tiny $omv $debian_pve; do
    echo "$server"
    kickstart deploy root@"$server" bootstrap-debian ssh-keys docker-ce
done

## Zerotier
false && for server in $archiver $pve $tiny $omv $debian_pve; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" connection <<<"$NETWORK_ID"
done

## PVE
# kickstart deploy root@"192.168.15.32" ssh-keys connection <<<"$NETWORK_ID"
# kickstart deploy root@"192.168.15.3" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.3" docker-ce monitoring consul-server <../secrets/consul.key
# kickstart deploy --sudo bltavares@"192.168.15.3" consul-server <../secrets/consul.key
# kickstart deploy --sudo bltavares@192.168.15.2 mediacenter
# kickstart deploy --sudo bltavares@192.168.15.2 bouncer

# kickstart deploy --sudo bltavares@archiver.zerotier.bltavares.com nomad-server <../secrets/nomad.key
# kickstart deploy --sudo bltavares@pve.zerotier.bltavares.com nomad-server <../secrets/nomad.key
# kickstart deploy --sudo bltavares@192.168.15.193 consul-client nomad-client <../secrets/consul.key

# kickstart deploy --sudo bltavares@controller.zerotier.bltavares.com nomad-server <../secrets/nomad.key
# kickstart deploy --sudo bltavares@p1.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p2.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p3.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p4.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key

# PVE: Debian vm
# kickstart deploy root@192.168.15.193 bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@192.168.15.193 docker-ce connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.193 consul-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@192.168.15.193 lab-web

## Controller
# kickstart deploy --sudo bltavares@"192.168.15.245" consul-client <../secrets/consul.key

## Pi Zeros
# P1
# kickstart deploy --sudo bltavares@"192.168.15.159" consul-client <../secrets/consul.key

# P2
# kickstart deploy --sudo bltavares@"192.168.15.160" consul-client <../secrets/consul.key

# P3
# kickstart deploy --sudo bltavares@192.168.15.163 ssh-keys connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@"192.168.15.163" consul-client <../secrets/consul.key

# P4
# kickstart deploy --sudo bltavares@192.168.15.162 ssh-keys connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@"192.168.15.162" consul-client <../secrets/consul.key

#Archiver
# kickstart deploy root@"192.168.15.2" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.10" docker-ce connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@"192.168.15.10" fileserver mediacenter
# kickstart deploy --sudo bltavares@"192.168.15.2" monitoring mediacenter
# kickstart deploy --sudo bltavares@"192.168.15.2" consul-server <../secrets/consul.key

# PVE Dat
# kickstart deploy root@192.168.15.213 bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@192.168.15.213 docker-ce connection <<<"$NETWORK_ID"

# With certificates
# kickstart deploy --sudo bltavares@192.168.15.2 bouncer
# kickstart deploy --sudo bltavares@192.168.15.193 lab-web

# Minecraft
# kickstart deploy root@"192.168.15.158" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.158" docker-ce connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@"192.168.15.158" minecraft

# zt
# kickstart deploy --sudo bltavares@192.168.15.2 connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.3 connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.4 connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.193 connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.218 connection <<<"$NETWORK_ID"

# kickstart deploy --sudo bltavares@192.168.15.193 prometheus
# kickstart deploy --sudo bltavares@192.168.15.193 grafana

# tiny
# kickstart deploy root@"192.168.15.4" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.4" docker-ce connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@192.168.15.4 consul-server <../secrets/consul.key
