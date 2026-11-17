#!/bin/sh
# Railway wrapper for Attu: prepares the root-owned Railway volume for the
# image's "node" user and refuses to start with an open first-run setup form.
set -eu

DB="${ATTU_DB_PATH:-/data/attu.db}"
DIR="$(dirname "$DB")"
mkdir -p "$DIR"
if [ "$(stat -c %U "$DIR")" != "node" ]; then
  chown -R node:node "$DIR"
fi

export ATTU_ADMIN_USER="${ATTU_ADMIN_USER:-admin}"
if [ "${ATTU_AUTH_MODE:-local}" = "local" ] && [ ! -s "$DB" ] && [ -z "${ATTU_ADMIN_PASSWORD:-}" ]; then
  # Without a bootstrap password, the first visitor of the public URL could
  # create the admin account.
  echo "railway-attu: ATTU_ADMIN_PASSWORD is empty on first boot; refusing to start" >&2
  exit 1
fi

exec runuser -u node -- docker-entrypoint.sh "$@"
