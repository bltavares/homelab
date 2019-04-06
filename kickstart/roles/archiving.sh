#!/bin/bash

docker pull nginx
docker rm -f archivebox
docker run --name archivebox \
    -p 8080:80 \
    -l SERVICE_NAME=archivebox \
    -v /media/onetb/Archive:/usr/share/nginx/html:ro \
    -d --restart unless-stopped nginx
