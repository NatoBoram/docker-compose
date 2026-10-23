#!/bin/sh

set -e

: "${FORGEJO_INSTANCE_URL:?Set FORGEJO_INSTANCE_URL}"
FORGEJO_HOST="$(printf '%s' "$FORGEJO_INSTANCE_URL" | jq --raw-input --exit-status --raw-output '
  [capture("^https://(?<host>[a-zA-Z0-9.-]+)(:443)?(/.*)?$")] |
  .[0].host // error("FORGEJO_INSTANCE_URL must use HTTPS on port 443")
')"
FORGEJO_ADDRESSES="$(getent ahostsv4 "$FORGEJO_HOST" | awk '{print $1}' | sort --unique)"
: "${FORGEJO_ADDRESSES:?Could not resolve Forgejo}"
REGISTRY_ADDRESS="$(getent ahostsv4 registry | awk 'NR == 1 {print $1}')"
: "${REGISTRY_ADDRESS:?Could not resolve the local registry}"
export REGISTRY_ADDRESS

# These rules live outside QEMU, in the outer container's network namespace.
# Leave Docker's embedded-DNS NAT rules intact.
iptables --policy OUTPUT DROP
ip6tables --policy OUTPUT DROP
iptables --new-chain RUNNER-EGRESS
iptables --append OUTPUT --jump RUNNER-EGRESS
iptables --append RUNNER-EGRESS --match conntrack --ctstate ESTABLISHED,RELATED --jump ACCEPT

# Docker translates DNS to a random loopback port before the filter table.
# Match the original destination so no other loopback service is allowed.
for DNS_ADDRESS in $(awk '$1 == "nameserver" {print $2}' /etc/resolv.conf); do
  for PROTOCOL in udp tcp; do
    iptables --append RUNNER-EGRESS --protocol "$PROTOCOL" \
      --match conntrack --ctorigdst "$DNS_ADDRESS" --ctorigdstport 53 --jump ACCEPT
  done
done
iptables --append RUNNER-EGRESS --destination "$REGISTRY_ADDRESS" --protocol tcp --destination-port 5000 --jump ACCEPT

# Permit Forgejo HTTPS, but not other published ports on the same host.
for ADDRESS in $FORGEJO_ADDRESSES; do
  iptables --append RUNNER-EGRESS --destination "$ADDRESS" --protocol tcp --destination-port 443 --jump ACCEPT
  iptables --append RUNNER-EGRESS --destination "$ADDRESS" --jump REJECT
done

for NETWORK in \
  0.0.0.0/8 \
  10.0.0.0/8 \
  100.64.0.0/10 \
  127.0.0.0/8 \
  169.254.0.0/16 \
  172.16.0.0/12 \
  192.0.0.0/24 \
  192.0.2.0/24 \
  192.168.0.0/16 \
  198.18.0.0/15 \
  198.51.100.0/24 \
  203.0.113.0/24 \
  224.0.0.0/4 \
  240.0.0.0/4; do
  iptables --append RUNNER-EGRESS --destination "$NETWORK" --jump REJECT
done
iptables --append RUNNER-EGRESS --match addrtype --dst-type LOCAL --jump REJECT
iptables --append RUNNER-EGRESS --jump ACCEPT

# Neither QEMU nor its descendants can change the firewall or regain capabilities.
exec setpriv --bounding-set=-all --inh-caps=-all --ambient-caps=-all --no-new-privs "$@"
