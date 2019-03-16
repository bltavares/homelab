#!/bin/bash

kickstart.context "Netboot provider"

docker run -d \
  --net=host \
  --restart unless-stopped \
  --name pixiecore danderson/pixiecore quick xyz
