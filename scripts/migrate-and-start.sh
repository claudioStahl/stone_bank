#!/bin/sh

set -e

until psql $DATABASE_URL '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

stone_bank eval "StoneBank.Release.migrate"
stone_bank start
