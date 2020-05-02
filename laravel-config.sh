#!/bin/bash

echo "----------------------------------------"
echo "Script para configuracion de permisos en un proyecto laravel"
echo "Recuerda tener tus archivos ya en el servidor"
read -p "Continuar? (y/n): " CONTINUE
echo "----------------------------------------"

if [ $CONTINUE = "y" ]; then
    echo "----------------------------------------"
    read -p "Ingresa tu host (puede ser subdominio): " HOST
    read -p "Ingresa tu dominio (sin punto inicial): " DOMAIN
    echo "----------------------------------------"

    echo "----------------------------------------"
    read -p "Configurar Laravel? (y/n): " LARAVEL
    echo "----------------------------------------"
    if [ $LARAVEL = "y" ]; then
        # permisos
        chown -R www-data:www-data /var/www/vhosts/$HOST.$DOMAIN
        find /var/www/vhosts/$HOST.$DOMAIN -type f -exec chmod 644 {} \;
        find /var/www/vhosts/$HOST.$DOMAIN -type d -exec chmod 755 {} \;

        # permisos a storage y cache de laravel
        chown -R www-data:www-data /var/www/vhosts/$HOST.$DOMAIN/web/storage
        chown -R www-data:www-data /var/www/vhosts/$HOST.$DOMAIN/web/bootstrap/cache
        chmod -R 775 /var/www/vhosts/$HOST.$DOMAIN/web/storage
        chmod -R 775 /var/www/vhosts/$HOST.$DOMAIN/web/bootstrap/cache

        # mover a root laravel
        cd /var/www/vhosts/$HOST.$DOMAIN/web

        # composer
        composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

        # configuraciones de laravel
        cp .env.example .env
        vim .env

        # key laravel
        php artisan key:generate

        # storage link
        rm public/storage
        php artisan storage:link

        # caches
        php artisan cache:clear
        php artisan auth:clear-resets
        php artisan route:clear
        php artisan route:cache
        php artisan config:clear
        php artisan config:cache
        php artisan queue:restart

        # frontend
        npm install
        npm run production
    fi
fi
