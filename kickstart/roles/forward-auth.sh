#!/bin/bash

set -e
kickstart.context "Traefik Forward Auth"

read -r COOKIE_SECRET DISCORD_OAUTH2_ID DISCORD_OAUTH2_SECRET
# https://discord.com/api/oauth2/token/revoke

docker pull thomseddon/traefik-forward-auth:2
docker rm -f forward-auth || true
docker run --name forward-auth \
	-l SERVICE_NAME="login" \
    -p 4181:4181 \
    --restart=unless-stopped -d \
	thomseddon/traefik-forward-auth:2 \
    --log-level=info \
    --default-provider=generic-oauth \
    --auth-host="login.lab.bltavares.com" \
    --cookie-domain="lab.bltavares.com" \
    --insecure-cookie \
    --domain="bltavares.com" \
    --providers.generic-oauth.auth-url="https://discord.com/api/oauth2/authorize" \
    --providers.generic-oauth.token-url='https://discord.com/api/oauth2/token' \
    --providers.generic-oauth.user-url='https://discord.com/api/users/@me' \
    --providers.generic-oauth.scope="identify email" \
    --secret="$COOKIE_SECRET" \
    --providers.generic-oauth.client-id="$DISCORD_OAUTH2_ID" \
    --providers.generic-oauth.client-secret="$DISCORD_OAUTH2_SECRET"

docker system prune -f
