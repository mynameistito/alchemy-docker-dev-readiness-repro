#!/usr/bin/env bash
set -euo pipefail
healthy="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://localhost:14337)"
container="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://localhost:14338)"
printf 'healthy worker: HTTP %s\ncontainer worker: HTTP %s\n' "$healthy" "$container"
if [[ "$healthy" != 200 || "$container" != 502 ]]; then
  echo 'Unexpected result; wait for startup and ensure only this repro owns these ports.' >&2
  exit 1
fi
echo 'Confirmed: healthy worker serves requests while container worker fails.'
