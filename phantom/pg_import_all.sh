#!/bin/sh

./pg_import.sh "authentik-postgres" "authentik"
./pg_import.sh "forgejo-postgres" "forgejo"
./pg_import.sh "nextcloud-postgres" "nextcloud"
