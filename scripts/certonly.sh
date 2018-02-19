#!/bin/bash

certbot certonly \
  --manual \
  --manual-public-ip-logging-ok \
  --preferred-challenges=dns \
  --manual-auth-hook "/dns_helper.sh auth" \
  --manual-cleanup-hook "/dns_helper.sh cleanup" \
  -d "$1"
