#!/bin/sh

./pg_dump.sh "authentik-postgres" "authentik"
./pg_dump.sh "forgejo-postgres" "forgejo"
./pg_dump.sh "nextcloud-postgres" "nextcloud"
