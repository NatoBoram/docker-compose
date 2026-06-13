#!/bin/sh

docker compose exec -u git forgejo forgejo "$@"
