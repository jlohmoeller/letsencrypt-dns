#!/bin/bash

certbot renew \
  --agree-tos \
  --quiet \
  --preferred-challenges=dns \
  --manual \
  --manual-public-ip-logging-ok \
  --manual-auth-hook "/dns_helper.sh auth" \
  --manual-cleanup-hook "/dns_helper.sh cleanup"

mkdir -p /certs/combined

for cert in $(ls /etc/letsencrypt/live) ; do
  certpath=/etc/letsencrypt/live/$cert
  if [ -d "$certpath" ]; then
    cat $certpath/fullchain.pem $certpath/privkey.pem > /certs/combined/$cert.pem
    cp $certpath/fullchain.pem /certs/$cert-chain.pem
    cp $certpath/privkey.pem /certs/$cert-key.pem
    cp $certpath/cert.pem /certs/$cert.pem
  fi
done
