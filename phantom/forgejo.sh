#!/bin/sh

docker compose exec -u 33 forgejo forgejo "$@"
