#!/bin/bash

kickstart.context "Linstore cluster"

if ! [[ -f /etc/apt/sources.list.d/linstore-drdb.sources ]]; then
	curl -fsSL https://packages.linbit.com/public/linbit-keyring.deb >/tmp/linbit-keyring.deb
	dpkg -i /tmp/linbit-keyring.deb

	cat >/etc/apt/sources.list.d/linstore-drdb.sources <<EOD
Types: deb
URIs: https://packages.linbit.com/public
Suites: proxmox-9
Components: drbd-9
Architectures: amd64
Signed-By: /etc/apt/trusted.gpg.d/linbit-keyring.gpg
EOD

	kickstart.package.update
fi

for p in proxmox-default-headers drbd-dkms drbd-utils linstor-satellite linstor-client cryptsetup; do
	kickstart.package.install $p
done

if ! kickstart.files.contains bltavares /etc/lvm/lvm.conf; then
	cat >>/etc/lvm/lvm.conf <<EOD
devices {
    # (bltavares): duplicates are ignored
	# avoid overloading lvm scans on remote filesystems
	global_filter = [ "r|/dev/zd.*|", "r|/dev/rbd.*|", "r|^/dev/drbd|", "r|^/dev/mapper/[lL]instor|" ]
}
EOD
fi

mkdir -p /etc/systemd/system/linstor-satellite.service.d/
cat >/etc/systemd/system/linstor-satellite.service.d/override.conf <<EOD
[Service]
Type=notify
TimeoutStartSec=infinity
Environment=LS_KEEP_RES=linstor_db
EOD

systemctl daemon-reload
systemctl enable --now linstor-satellite

if uname -r | kickstart.stream.contains pve; then
	# only run controllers on compute nodes to avoid taxing NAS
	kickstart.package.install linstor-controller
	kickstart.package.install drbd-reactor
	cat <<EOF >/etc/systemd/system/var-lib-linstor.mount
[Unit]
Description=Filesystem for the LINSTOR controller

[Mount]
# you can use the minor like /dev/drbdX or the udev symlink
What=/dev/drbd/by-res/linstor_db/0
Where=/var/lib/linstor
EOF

	cat <<EOF >/etc/drbd-reactor.d/linstor_db.toml
[[promoter]]
[promoter.resources.linstor_db]
start = ["var-lib-linstor.mount", "linstor-controller.service"]
EOF

	systemctl enable --now drbd-reactor

	# kickstart.package.install linstor-gui

	# Proxmox integration
	kickstart.package.install linstor-proxmox
fi
