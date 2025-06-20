#!/bin/sh

echo Client ID:
docker run --rm authelia/authelia:latest authelia crypto rand --length 72 --charset rfc3986
echo

echo Client Secret:
docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
