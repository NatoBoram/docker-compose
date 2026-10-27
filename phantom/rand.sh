#!/bin/sh

# rand.sh generates ~512 bits of entropy for passwords and keys.

# A 465 bits password that maxes out the input length of bcrypt.
echo 'Password (bcrypt):'
printf '%s\n\n' "$(openssl rand 256 | tr -dc '[:graph:]' | tr -d "\'\"\\\#\$" | head -c 72)"

# 528 bits to fill the padding of the base64 encoding.
echo 'Key (base64):'
printf '%s\n\n' "$(openssl rand 66 | openssl enc -A -base64)"

echo 'Key (hex):'
openssl rand -hex 64
