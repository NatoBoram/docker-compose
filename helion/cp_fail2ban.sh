#!/bin/sh
sudo cp ./fail2ban/filter.d/* /etc/fail2ban/filter.d/
sudo cp ./fail2ban/jail.d/* /etc/fail2ban/jail.d/

sudo fail2ban-client restart

sudo fail2ban-client status caddy
sudo fail2ban-client status jellyfin
sudo fail2ban-client status nextcloud
sudo fail2ban-client status planka
