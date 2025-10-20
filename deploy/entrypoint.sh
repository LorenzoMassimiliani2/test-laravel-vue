#!/usr/bin/env bash
set -e

# Variabili utili
export APP_ENV=${APP_ENV:-production}
export APP_DEBUG=${APP_DEBUG:-false}

# Genera APP_KEY se non presente
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "" ]; then
  echo "Generating APP_KEY..."
  php83 artisan key:generate --force
fi

# Esegui migrazioni (se DB configurato)
if [ ! -z "${DB_CONNECTION}" ]; then
  echo "Running migrations..."
  php83 artisan migrate --force || echo "Migrations skipped/failed (check DB config)"
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
