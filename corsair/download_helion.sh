#!/bin/sh

mkdir -p helion/env
mkdir -p helion/volumes

systemd-inhibit rsync --archive --delete --info=progress2 --progress --stats 'helion:Code/github.com/NatoBoram/docker-compose/helion/.env.*.local' helion/env/
systemd-inhibit rsync --archive --delete --info=progress2 --progress --stats 'root@helion:/var/lib/docker/volumes/helion_*' helion/volumes/
# systemctl poweroff
