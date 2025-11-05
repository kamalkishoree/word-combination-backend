# ========================
# 1️⃣ Base PHP image
# ========================
FROM php:8.2-fpm AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer (latest stable)
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

COPY . .

# ======================================
# 2️⃣ Production stage (optimized build)
# ======================================
FROM base AS production

# Copy application code
COPY --from=base /var/www /var/www

WORKDIR /var/www

# Optimize Laravel for production
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

EXPOSE 9000
CMD ["php-fpm"]

# ======================================
# 3️⃣ Development stage (with Xdebug)
# ======================================
FROM base AS development

ARG XDEBUG_ENABLED=true
ARG XDEBUG_MODE=develop,debug,profile
ARG XDEBUG_HOST=host.docker.internal
ARG XDEBUG_IDE_KEY=DOCKER

RUN if [ "${XDEBUG_ENABLED}" = "true" ]; then \
    pecl install xdebug && docker-php-ext-enable xdebug && \
    echo "xdebug.mode=${XDEBUG_MODE}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.client_host=${XDEBUG_HOST}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.idekey=${XDEBUG_IDE_KEY}" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ; \
fi

# Set permissions and PHP-FPM user
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
USER www-data

WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
