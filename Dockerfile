# --- Stage 1: Install PHP dependencies with Composer ---
FROM composer:2 AS vendor

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# --- Stage 2: Build frontend assets with Node/Vite ---
FROM node:20-alpine AS assets

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY resources ./resources
COPY vite.config.js ./vite.config.js
COPY public ./public
RUN npm run build

# --- Stage 3: Runtime with PHP-FPM + Nginx supervised ---
FROM php:8.2-fpm-alpine AS runtime

ENV APP_ENV=production \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=256 \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER=16

WORKDIR /var/www/html

# System deps: nginx, supervisor, and useful tools
RUN apk add --no-cache nginx supervisor bash curl git icu-data-full icu-libs libzip-dev oniguruma-dev libpng-dev libjpeg-turbo-dev libwebp-dev libxml2-dev freetype-dev postgresql-dev

# PHP extensions commonly needed by Laravel
RUN docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype \
    && docker-php-ext-install -j"$(nproc)" gd pdo pdo_mysql pdo_pgsql mbstring xml zip intl opcache

# Copy application code
COPY . .

# Copy vendor from Composer stage
COPY --from=vendor /app/vendor ./vendor

# Copy built assets from Node stage
COPY --from=assets /app/public/build ./public/build

# Nginx + Supervisor configs
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

# Ensure proper permissions
RUN addgroup -g 1000 -S www && adduser -S www -G www -u 1000 \
    && chown -R www:www /var/www/html \
    && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]


