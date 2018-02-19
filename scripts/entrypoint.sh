#!/bin/bash
set -eo pipefail

if [ "$1" = "" ]; then
  exec /renew.sh
elif [ "$1" = "cert" ]; then
  exec /certonly.sh "$2"
fi

exec "$@"
