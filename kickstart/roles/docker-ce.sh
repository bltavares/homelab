#!/bin/bash

kickstart.context "Docker CE"

if [[ $(kickstart.package.manager) == "apt-get" ]]; then
	packages=(
		ca-certificates
		curl
		gnupg2
	)

	for package in ${packages[*]}; do
		kickstart.package.install "$package"
	done

	if ! [[ -f /etc/apt/sources.list.d/docker-ce.sources ]]; then
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.asc

		cat >/etc/apt/sources.list.d/docker-ce.sources <<EOD
Types: deb
URIs: https://download.docker.com/linux/debian/
Suites: trixie
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOD

		kickstart.package.update
	fi

	packages=(docker-ce docker-ce-cli containerd.io)
	for package in ${packages[*]}; do
		kickstart.package.install "$package"
	done
elif [[ $(kickstart.package.manager) == "zypper" ]]; then
	packages=(
		docker containerd docker-compose
	)
	for package in ${packages[*]}; do
		kickstart.package.install "$package"
	done
fi

if kickstart.user.exists bltavares; then
	kickstart.user.add_group bltavares docker
fi

kickstart.service.enable docker
kickstart.service.start docker

if ! [[ -f /etc/docker/daemon.json ]]; then
	cp -f files/docker/daemon.json /etc/docker/daemon.json
	kickstart.service.restart docker
fi

docker ps
