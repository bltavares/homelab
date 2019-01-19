#!/bin/bash

set -e
kickstart.mute 'docker ps -a' || {
  apt-get update
  # Needed for Docker bug: https://github.com/moby/moby/issues/38175
  apt-get install -y --allow-downgrades docker-ce=18.06.1~ce~3-0~raspbian
  kickstart.service.restart docker
}
