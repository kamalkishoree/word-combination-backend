#!/usr/bin/env bash
set -euo pipefail

# Ensure runtime permissions
chown -R www:www /var/www/html/storage /var/www/html/bootstrap/cache || true
chmod -R ug+rwX /var/www/html/storage /var/www/html/bootstrap/cache || true

# Laravel optimizations if env is present
if [ -f /var/www/html/.env ]; then
  su -s /bin/sh -c "php artisan key:generate --force || true" www || true
  su -s /bin/sh -c "php artisan config:cache || true" www || true
  su -s /bin/sh -c "php artisan route:cache || true" www || true
  su -s /bin/sh -c "php artisan view:cache || true" www || true
  su -s /bin/sh -c "php artisan storage:link || true" www || true
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf


