#!/bin/bash

set -e
kickstart.context "Bootstrap"

kickstart.package.update
kickstart.package.install sudo
kickstart.package.install mosh

kickstart.user.exists bltavares || kickstart.user.create bltavares

cat >/etc/sudoers.d/bltavares <<<"
bltavares ALL=(ALL) NOPASSWD:ALL
"

chmod 444 /etc/sudoers.d/bltavares
