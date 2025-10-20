#!/usr/bin/env bash
set -e
cd /var/www/html

# Porta: esporta per envsubst (importantissimo)
export PORT="${PORT:-8080}"

# Materializza la config di nginx sostituendo $PORT
envsubst '$PORT' </etc/nginx/http.d/default.conf.template >/etc/nginx/http.d/default.conf

# (debug utile) mostra la riga listen e valida la config
grep -n 'listen' /etc/nginx/http.d/default.conf || true
nginx -t

# Assicura .env per comandi che lo richiedono
[ ! -f ".env" ] && [ -f ".env.example" ] && cp .env.example .env || true

# Pulisci cache nel caso una build precedente l'abbia creata
php83 artisan config:clear || true

# APP_KEY
if [ -z "${APP_KEY}" ]; then
  echo "APP_KEY mancante: genero in .env..."
  php83 artisan key:generate --force --no-interaction || true
else
  echo "APP_KEY presente nelle ENV: salto key:generate"
fi

php83 artisan storage:link || true
[ -n "${DB_CONNECTION}" ] && php83 artisan migrate --force || true

php83 artisan route:cache || true
php83 artisan view:cache || true
php83 artisan config:cache || true

exec /usr/bin/supervisord -c /etc/supervisord.conf
