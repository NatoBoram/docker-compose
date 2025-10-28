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

docker exec -i "$service" psql -U "$user" < "$service.sql"
