#!/bin/bash

NSUPDATE_KEY="/etc/letsencrypt/dns.key"
NSUPDATE_SERVER="dns-master.lmlr.de"

# Add TXT validation
dns_add() {
  nsupdate -k "${NSUPDATE_KEY}" <<EOF
server ${NSUPDATE_SERVER}
update add _acme-challenge.${CERTBOT_DOMAIN}. 60 IN TXT "$CERTBOT_VALIDATION"
send
EOF
sleep 3
}

# Remove TXT validation
dns_rm() {
  nsupdate -k "${NSUPDATE_KEY}" <<EOF
server ${NSUPDATE_SERVER}
update delete _acme-challenge.${CERTBOT_DOMAIN}. TXT
send
EOF
}

case "$1" in
  auth)
    dns_add
    ;;
  cleanup)
    dns_rm
    ;;
  *)
    echo "Usage: $0 {auth|cleanup}"
esac

