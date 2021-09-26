#!/bin/bash
set -ueo pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}/../../secrets/env.sh"

archiver="192.168.15.2"
pve="192.168.15.3"
tiny="192.168.15.4"
omv="192.168.15.5"
debian_pve="192.168.15.193"
pve_dat="192.168.15.213"

## Bootstrap
false && for server in $archiver $pve $tiny $omv $debian_pve $pve_dat; do
    echo "$server"
    kickstart deploy root@"$server" bootstrap-debian ssh-keys docker-ce
done

## Zerotier
false && for server in $archiver $pve $tiny $omv $debian_pve $pve_dat; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" connection <<<"$NETWORK_ID"
done

## Bouncer (SSL)
false && kickstart deploy --sudo bltavares@"$archiver" bouncer

## Traefik proxy (SSL)
false && kickstart deploy --sudo bltavares@"$debian_pve" lab-web

# Mediacenter
false && kickstart deploy --sudo bltavares@"$archiver" mediacenter

# Archivebox
false && kickstart deploy --sudo bltavares@"$omv" archiving

## Consul/Nomad client
## OMV skipped as consul generates too many logs for a USB drive
false && for server in $debian_pve; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" consul-client nomad-client <../secrets/consul.key
done

## Consul/Nomad server
false && for server in $archiver $pve $tiny; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" consul-server nomad-server <../secrets/consul.key
done

## Gitea
false && kickstart deploy --sudo bltavares@"$debian_pve" gitea

# Legacy

## Brumble
# kickstart deploy --sudo bltavares@controller.zerotier.bltavares.com nomad-server <../secrets/nomad.key
# kickstart deploy --sudo bltavares@p1.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p2.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p3.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key
# kickstart deploy --sudo bltavares@p4.zerotier.bltavares.com consul-client nomad-client <../secrets/consul.key

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

# Minecraft
# kickstart deploy root@"192.168.15.158" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.158" docker-ce connection <<<"$NETWORK_ID"
# kickstart deploy --sudo bltavares@"192.168.15.158" minecraft

# Monitoring (prototype)
# kickstart deploy --sudo bltavares@192.168.15.193 prometheus
# kickstart deploy --sudo bltavares@192.168.15.193 grafana