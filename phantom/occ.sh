#!/bin/sh

docker compose exec -u 33 nextcloud ./occ $@
