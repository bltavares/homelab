#!/bin/bash
set -eo pipefail

current_dir=$(dirname "${BASH_SOURCE[0]}")
source "${current_dir}/../secrets/env.sh"

## PVE
#kickstart deploy root@"192.168.15.32" connection <<<"$NETWORK_ID"

## Controller
#kickstart deploy --sudo bltavares@"fe80::ba27:ebff:fef1:7e91%9" connection <<<"$NETWORK_ID"

## Pi Zeros
#kickstart deploy --sudo bltavares@"192.168.15.19" downgrade-docker connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.18" downgrade-docker connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.17" downgrade-docker connection <<<"$NETWORK_ID"

#kickstart deploy --sudo bltavares@"192.168.15.16" downgrade-docker connection <<<"$NETWORK_ID"
