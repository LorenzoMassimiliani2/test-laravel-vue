#!/usr/bin/env bash
set -e
cd /var/www/html

# subito dopo "cd /var/www/html", aggiungi:
: "${PORT:=8080}"  # default locale
envsubst '$PORT' </etc/nginx/http.d/default.conf.template >/etc/nginx/http.d/default.conf


# Se manca .env ma c'è .env.example, creane uno (alcuni comandi lo richiedono)
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
fi

if [ -z "${APP_KEY}" ]; then
  echo "APP_KEY non presente: genero chiave in .env..."
  php83 artisan key:generate --force --no-interaction || true
else
  echo "APP_KEY fornita via env: salto key:generate"
fi

if [ -n "${DB_CONNECTION}" ]; then
  echo "Eseguo migrazioni..."
  php83 artisan migrate --force || echo "Migrazioni saltate/fallite (controlla config DB)"
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
