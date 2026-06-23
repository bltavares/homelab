#!/bin/bash

kickstart.context "opkssh"

groupadd --system opksshuser || true
kickstart.user.exists opksshuser || useradd -r -M -s /sbin/nologin -g opksshuser opksshuser

OPKSSH_PATH=/usr/local/bin/opkssh

(
	CPU_ARCH=""
	case "$(uname -m)" in
	x86_64)
		CPU_ARCH="amd64"
		;;
	*)
		CPU_ARCH="arm64"
		;;
	esac

	VERSION="v0.14.0"
	GITHUB_REPO="openpubkey/opkssh"
	BINARY_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/opkssh-linux-$CPU_ARCH"
	kickstart.download.file "$BINARY_URL" $OPKSSH_PATH
	chmod 755 $OPKSSH_PATH
	chown root:opksshuser $OPKSSH_PATH
)

cat > /etc/ssh/sshd_config.d/opkssh.conf <<CONF
AuthorizedKeysCommand ${OPKSSH_PATH} verify %u %k %t
AuthorizedKeysCommandUser opksshuser
CONF

mkdir -p /etc/opk
cat > /etc/opk/providers <<EOF
https://id.bltavares.com/auth/v1/ opkssh 24h
EOF
cp files/secrets/opkssh-auth_id /etc/opk/auth_id
chmod 640 /etc/opk/*
chown -R root:opksshuser /etc/opk

# reset log
: > /var/log/opkssh.log
chmod 660 /var/log/opkssh.log
chown root:opksshuser /var/log/opkssh.log

systemctl reload sshd || systemctl reload ssh || true
