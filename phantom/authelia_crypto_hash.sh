#!/bin/sh

docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password $@
