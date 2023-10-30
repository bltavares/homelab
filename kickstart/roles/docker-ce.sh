#!/bin/bash

kickstart.context "Docker CE"

if [[ $(kickstart.package.manager) == "apt-get" ]]; then
    packages=(
        apt-transport-https
        ca-certificates
        curl
        gnupg2
        software-properties-common
    )

    for package in ${packages[*]}; do
        kickstart.package.install "$package"
    done

    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

    if ! [[ -f /etc/apt/sources.list.d/docker-ce.list ]]; then
        cat >/etc/apt/sources.list.d/docker-ce.list <<<"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
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
