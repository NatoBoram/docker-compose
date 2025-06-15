#!/bin/sh

systemd-inhibit rsync --archive --delete --info=progress2 --progress --stats 'helion/env' 'phantomwifi:Desktop/'
systemd-inhibit rsync --archive --delete --info=progress2 --progress --stats 'helion/volumes' 'phantomwifi:Desktop/'
