#!/bin/sh

echo "Password (bcrypt):"
printf '%s\n' "$(openssl rand 256 | tr -dc '[:graph:]' | tr -d "\'\"\\\#\$" | head -c 72)"
echo

echo "Key (base64):"
printf '%s\n' "$(openssl rand 66 | openssl enc -A -base64)"
echo

echo "Key (hex):"
openssl rand -hex 64
echo
