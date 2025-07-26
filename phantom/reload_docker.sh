#!/bin/sh

docker pull caddy:builder
docker pull caddy:latest
docker pull jellyfin/jellyfin

docker compose pull
docker compose build --pull
docker compose down --remove-orphans
docker compose up -d
