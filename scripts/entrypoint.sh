#!/bin/bash
set -eo pipefail

if [ "$1" = "" ]; then
  exec /scripts/renew.sh
elif [ "$1" = "cert" ]; then
  exec /scripts/certonly.sh "$2"
fi

exec "$@"
