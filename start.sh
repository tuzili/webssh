#!/bin/sh
set -eu

PORT="${PORT:-8080}"

exec python3 run.py \
  --address=127.0.0.1 \
  --port="${PORT}" \
  --policy=warning \
  --xheaders=True \
  --fbidhttp=False
