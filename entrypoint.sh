#!/bin/bash
set -eo pipefail

if ["$1" = ""]; then
  exec /renew.sh
fi

exec "$@"
