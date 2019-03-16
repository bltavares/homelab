#!/bin/bash

set -e
kickstart.context "Bootstrap Debian"

kickstart.package.update
kickstart.package.install sudo

cat >/etc/sudoers.d/bltavares <<<"
bltavares ALL=(ALL) NOPASSWD:ALL
"
chmod 444 /etc/sudoers.d/bltavares
