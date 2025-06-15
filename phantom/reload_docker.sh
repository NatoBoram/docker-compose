#!/bin/sh

docker pull caddy:builder
docker pull caddy:latest
docker pull jellyfin/jellyfin

docker compose pull
docker compose build
docker compose down --remove-orphans
docker compose up -d
