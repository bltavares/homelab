#!/bin/bash

kickstart.context "SSH Keys"

cat >/etc/systemd/system/github-keys@.timer <<<'
[Unit]
Description=Import keys on boot and keep updated
[Timer]
OnBootSec=1min
OnUnitActiveSec=1h
[Install]
WantedBy=timers.target'

cat >/etc/systemd/system/github-keys@.service <<<'
[Unit]
Description=Import keys for %i
Wants=network-online.target
After=network-online.target
[Service]
Type=oneshot
ExecStart=/usr/bin/ssh-import-id gh:bltavares
User=%i'

kickstart.package.install ssh-import-id

systemctl enable github-keys@root.timer
systemctl start github-keys@root

if kickstart.user.exists bltavares; then
  systemctl enable github-keys@bltavares.timer
  systemctl start github-keys@bltavares
fi
