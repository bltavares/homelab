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
citadel="REDACTED"
ryzen="192.168.15.6"
gibson="192.168.15.195"

## Bootstrap
true && for server in $archiver $pve $tiny $omv $ryzen $gibson; do
    echo "$server"
    kickstart deploy root@"$server" bootstrap ssh-keys docker-ce
done

## Zerotier
true && for server in $archiver $pve $tiny $omv $ryzen $gibson; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" connection <<<"$NETWORK_ID"
done

## Consul/Nomad client
## OMV skipped as consul generates too many logs for a USB drive
false && for server in false; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" consul-client  <../secrets/consul.key
    kickstart deploy --sudo bltavares@"$server" nomad-client <../secrets/nomad.key
done

## Consul/Nomad server
true && for server in $ryzen; do
    echo "$server"
    kickstart deploy --sudo bltavares@"$server" consul-server <../secrets/consul.key
    kickstart deploy --sudo bltavares@"$server" nomad-server <../secrets/nomad.key
done

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
# kickstart deploy root@"192.168.15.157" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.157" docker-ce connection <<<"$NETWORK_ID"
# false && kickstart deploy --sudo bltavares@"192.168.15.157" minecraft