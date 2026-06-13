#!/bin/sh

./forgejo.sh manager flush-queues
./forgejo.sh dump --file /data/dump.zip
sudo mv /var/lib/docker/volumes/phantom_forgejo/_data/dump.zip dump.zip
sudo chown $USER:$USER -Rc dump.zip
