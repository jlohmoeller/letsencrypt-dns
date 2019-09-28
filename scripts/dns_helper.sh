#!/bin/bash

if [ -z "$NSUPDATE_TOKEN"]
then
  echo "No credentials for nsupdate specified! Specify credentials for nsupdate in NSUPDATE_TOKEN"
  exit 1
fi

if [ -z "$NSUPDATE_SERVER"]
then
  echo "No server for nsupdate specified! Use NSUPDATE_SERVER to specify the address of the master nameserver"
  exit 2
fi

if [ -z "$PROPAGATION_TIME"]
then
  PROPAGATION_TIME=10
fi


# Add TXT validation
dns_add() {
  nsupdate -y "${$NSUPDATE_TOKEN}" <<EOF
server ${NSUPDATE_SERVER}
update add _acme-challenge.${CERTBOT_DOMAIN}. 60 IN TXT "$CERTBOT_VALIDATION"
send
EOF
# Wait some time until changes are propagted
sleep $PROPAGATION_TIME
}

# Remove TXT validation
dns_rm() {
  nsupdate -y "${$NSUPDATE_TOKEN}" <<EOF
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

