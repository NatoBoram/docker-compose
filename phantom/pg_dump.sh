#!/bin/sh

# Services:
# * authentik-postgres
# * forgejo-postgres
# * nextcloud-postgres
service=$1

# Users:
# * authentik
# * forgejo
# * nextcloud
user=$2

echo "Service: $service"
echo "User: $user"

docker exec -it "$service" pg_dumpall -U $user > "$service.sql"
