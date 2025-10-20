# ---- Vendor (Composer) ----
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-scripts --optimize-autoloader
COPY . .
RUN composer dump-autoload --optimize \
 && php artisan config:clear || true

# ---- Frontend (Vite) ----
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN if [ -f package-lock.json ]; then npm ci; \
    elif [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f pnpm-lock.yaml ]; then npm i -g pnpm && pnpm i --frozen-lockfile; \
    else npm i; fi
COPY . .
RUN npm run build

# ---- Runtime (nginx + php-fpm in un unico container) ----
FROM alpine:3.20

# Pacchetti di base
RUN apk add --no-cache \
    nginx \
    php83 php83-fpm php83-opcache php83-pdo php83-pdo_mysql php83-mbstring php83-xml php83-ctype php83-json php83-tokenizer php83-fileinfo php83-session php83-curl php83-bcmath php83-intl php83-zip php83-dom \
    php83-pgsql php83-pdo_pgsql \
    supervisor curl bash gettext

ENV APP_DIR=/var/www/html
WORKDIR $APP_DIR

# Copia app, vendor e assets
COPY --from=vendor /app $APP_DIR
COPY --from=vendor /app/vendor $APP_DIR/vendor
COPY --from=frontend /app/public/build $APP_DIR/public/build

# Nginx config (ascolta su $PORT per Railway)
COPY ./deploy/nginx.conf /etc/nginx/http.d/default.conf.template

# Supervisor per avviare php-fpm + nginx
COPY ./deploy/supervisord.conf /etc/supervisord.conf

# Permessi storage/bootstrap
RUN mkdir -p storage/framework/{cache,sessions,views} \
 && chown -R nobody:nogroup storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Ottimizzazioni Laravel in build
RUN php83 -d detect_unicode=0 artisan storage:link || true \
 && php83 artisan route:cache || true \
 && php83 artisan config:cache || true \
 && php83 artisan view:cache || true

# Entry script: migrazioni e avvio servizi
COPY ./deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Railway imposta $PORT -> di default 8080 se non presente
ENV PORT=8080
EXPOSE 8080

CMD ["/entrypoint.sh"]
