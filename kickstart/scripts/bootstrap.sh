#!/bin/bash
set -ueo pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}/../../secrets/env.sh"

## PVE
#kickstart deploy root@"192.168.15.32" ssh-keys connection <<<"$NETWORK_ID"
#kickstart deploy root@"192.168.15.3" bootstrap-debian ssh-keys
# kickstart deploy --sudo bltavares@"192.168.15.3" docker-ce monitoring consul-server <../secrets/consul.key
kickstart deploy --sudo bltavares@192.168.15.3 lab-web
#kickstart deploy --sudo bltavares@192.168.15.2 mediacenter

## Controller
#kickstart deploy --sudo bltavares@"fe80::ba27:ebff:fef1:7e91%9" ssh-keys connection <<<"$NETWORK_ID"

## Pi Zeros
#kickstart deploy --sudo bltavares@"192.168.15.19" ssh-keys connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.18" ssh-keys connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.17" ssh-keys connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.16" ssh-keys connection <<<"$NETWORK_ID"

#Archiver
#kickstart deploy root@"192.168.15.2" bootstrap-debian ssh-keys
#kickstart deploy --sudo bltavares@"192.168.15.10" docker-ce connection <<<"$NETWORK_ID"
#kickstart deploy --sudo bltavares@"192.168.15.10" fileserver mediacenter
#kickstart deploy --sudo bltavares@"192.168.15.2" monitoring mediacenter

# LibreElec
#kickstart deploy --sudo bltavares@"192.168.15.2" consul-server <../secrets/consul.key
